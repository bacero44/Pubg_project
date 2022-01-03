# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader' if development?
require 'json'
require 'dotenv/load'
require './pubg'
require './player'
require './redis'

# 3600 === 1 hour
REFRESHMENT_TIME = 300
get '/' do
  @consoles = %w[xbox playstation stadia]
  erb :index, :layout => :l_main
end

get '/:console/:player_name/json' do
  content_type 'application/json'
  console = params[:console]
  player_name = params[:player_name]
  stats = get_stats(console, player_name)
  if stats
    json_response(stats, 200)
  else
    json_response({ "message": " We can't found the player" }, 404)
  end
end

get '/:console/:player_name/current/json' do
  content_type 'application/json'
  console = params[:console]
  player_name = params[:player_name]
  stats = get_stats(console, player_name, true)
  if stats
    json_response(stats, 200)
  else
    json_response({ "message": " We can't found the player" }, 404)
  end
end

get '/:console/:player_name' do
  console = params[:console]
  @player_name = params[:player_name]
  @stats = get_stats(console, @player_name)
  if @stats
    @stats = @stats.transform_keys(&:to_sym)
    erb :stats
  end
end

get '/:console/:player_name/current' do
  console = params[:console]
  @player_name = params[:player_name]
  @stats = get_stats(console, @player_name, true)
  if @stats
    @stats = @stats.transform_keys(&:to_sym)
    erb :stats
  end
end


def get_stats(console,player_name, current = false)
  # CACHE
  redis = Redis.get_player(console, player_name)
  if redis && ((Time.now - Time.parse(redis['date'].to_s)) < REFRESHMENT_TIME)
    # puts " ***** cache response **********"
    current ? redis['season'] : redis['stats']
  else
    # puts " ***** Normal response **********"
    id = redis ? redis['id'] : nil
    player = Player.new(console, player_name, id)
    if player.found?
      player.save
      current ? player.season_stats : player.stats
    else
      false
    end
  end
end

def json_response(payload, status_code)
  status status_code
  payload.to_json
end
