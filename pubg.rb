# frozen_string_literal: true

require 'httparty'

# Class to consume Api
class Pubg
  attr_reader :id

  def initialize(console, player_name, id = nil)
    @stats = nil
    @id = id
    player_id(console, player_name) if id.nil?
  end

  def stats
    lifetime if !@id.nil? && @stats.nil?
    @stats
  end

  def player_id(console, player_name)
    if @id.nil?
      r = request("https://api.pubg.com/shards/#{console}/players?filter[playerNames]=#{player_name}")
      case r.code
      when 200
        @id = r['data'][0]['id']
      else
        error_details(r)
        false
      end
    end
  end

  def lifetime
    unless @id.nil?
      r = request("https://api.pubg.com/shards/xbox/players/#{@id}/seasons/lifetime")
      case r.code
      when 200
        @stats = r['data']['attributes']['gameModeStats']
      else
        error_details(r)
        false
      end
    end
  end

  private

  # generic API's request
  def request(url)
    puts 'Entra al request-----------------------!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
    HTTParty.get(url, headers: {
      'Content-Type' => 'application/json',
      'accept' => 'application/vnd.api+json',
      'Authorization' => " Bearer #{ENV["PUBG_API_KEY"]}"
    })
  end

  # Error method
  def error_details(_data)
    # TODO: Create handle to errors
  end
end
