# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader' if development?
require 'json'
require 'dotenv/load'
require './pubg'
require './player'
require './redis'
require './memory'

# 3600 === 1 hour
REFRESHMENT_TIME = 300
CACHE = RedisCache.active? ? RedisCache : MemoryCache
puts "------------------------------------------------------------"
puts CACHE
puts "------------------------------------------------------------"
get '/' do
  @consoles = %w[xbox psn stadia]
  erb :index, :layout => :l_main
end

get '/:console/:player_name/json' do
  json_process
end

get '/:console/:player_name/current/json' do
  json_process(true)
end

get '/:console/:player_name' do
  html_process
end

get '/:console/:player_name/current' do
  html_process(true)
end

def html_process(current = false)
  @console = params[:console]
  @player_name = params[:player_name]
  @current = current
  @stats = player_data(@console, @player_name)
  if @stats[:error]
    erb :error , :layout => :l_main
  elsif !@stats[:found]
    erb :notfound , :layout => :l_main
  else
    @stats = @current ? @stats[:season_stats] : @stats[:stats]
    @stats = @stats.transform_keys(&:to_sym)
    erb :stats
  end
end

def json_process(current = false)
  content_type 'application/json'

  console = params[:console]
  player_name = params[:player_name]
  
  stats = player_data(console, player_name)
  if stats[:error]
    json_response({ "message": " cannot be processed at this time" }, 500)
  elsif !stats[:found]
    json_response({ "message": " We can't found the player" }, 404)
  else
    stats = current ? stats[:season_stats] : stats[:stats]
    stats = stats.transform_keys(&:to_sym)
    json_response(stats, 200)
  end

end

def player_data(console, player_name)
  player = Player.new(console, player_name)
  {
    error: player.error,
    found: player.found?,
    stats: player.stats,
    season_stats: player.season_stats
  }
end

def json_response(payload, status_code)
  status status_code
  payload.to_json
end
