# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader' if development?
require 'json'
require 'dotenv/load'
require './pubg'
require './player'
require './redis'

# 3600 === 1 hour
REFRESHMENT_TIME = 5

get '/:console/:player_name/json' do
  console = params[:console]
  player_name = params[:player_name]
  #CACHE
  redis = Redis.get_player(console, player_name)
  if redis && ((Time.now - Time.parse(redis['date'].to_s)) < REFRESHMENT_TIME)
    # puts " ***** cache response **********"
    json_response(redis['stats'], 200)
  else
    # puts " ***** Normal response **********"
    player = Player.new(console, player_name)
    if player.found?
      player.save
      json_response(player.stats, 200)
    else
      json_response({ "message": " We can't found the player" }, 404)
    end
  end
  
end

get '/:console/:player' do
  'Hi Bacero44! '
end

def json_response(payload, status_code)
  status status_code
  payload.to_json
end
