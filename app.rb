# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader' if development?
require 'json'
require './pubg'
require './player'
require 'dotenv/load'


get '/:console/:player_name/json' do
  console = params[:console]
  player_name = params[:player_name]
  player = Player.new(console, player_name)
  if player.found?
    json_response(player.stats, 200)
  else
    json_response({ "message": " We can't found the player" }, 404)
  end
end

get '/:console/:player' do
  'Hi Bacero44! '
end

def json_response(payload, status_code)
  status status_code
  payload.to_json
end
