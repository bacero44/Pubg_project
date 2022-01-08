# frozen_string_literal: true

require 'httparty'

# Class to consume Api
class Pubg
  attr_reader :id, :stats, :season_stats

  def initialize(console, player_name, id = nil)
    @id = id
    @console = console
    @player_name = player_name
    @overlimited = false
    @id = player_id if id.nil?
    @stats = read_stats
    @season_id = current_season
    @season_stats = read_season_stats
  end

  def overlimited?
    @overlimited
  end

  def found?
    !@id.nil? && @id != false ? true : false
  end

  private

  def player_id
    r = request("https://api.pubg.com/shards/#{@console}/players?filter[playerNames]=#{@player_name}")
    if r.code == 200
      r['data'][0]['id']
    else
      error_details(r.code, r)
      false
    end
  end

  def read_stats
    if possible_request?
      r = request("https://api.pubg.com/shards/#{@console}/players/#{@id}/seasons/lifetime")
      if r.code == 200
        r['data']['attributes']['gameModeStats']
      else
        error_details(r.code, r)
        false
      end
    else
      false
    end
  end

  def read_season_stats
    if possible_request? && @season_id
      r = request("https://api.pubg.com/shards/#{@console}/players/#{@id}/seasons/#{@season_id}")
      if r.code == 200
        r['data']['attributes']['gameModeStats']
      else
        error_details(r.code, r)
        false
      end
    else
      false
    end
  end

  def current_season
    cache = CACHE.get_current_season(@console)
    if cache && ((Time.now - Time.parse(cache['date'].to_s)) < 43_200)
      cache['id']
    else
      r = request("https://api.pubg.com/shards/#{@console}/seasons")
      case r.code
      when 200
        id = r['data'].find { |x| x['attributes']['isCurrentSeason'] }['id']
        CACHE.save_current_season(@console, id)
        id
      when 429
        @overlimited = true
        false
      else
        error_details(r)
        false
      end
    end
  end

  # generic API's request

  def request(url)
    # puts '============================================================================================='
    # puts "==   Entra al request--FROM: #{caller_locations(1,1)[0].label}                             == "
    # puts '============================================================================================='
    HTTParty.get(
      url,
      headers: {
        'Content-Type' => 'application/json',
        'accept' => 'application/vnd.api+json',
        'Authorization' => " Bearer #{ENV["PUBG_API_KEY"]}"
      }
    )
  end

  # Error method
  def error_details(code, _data)
    @overlimited = true if code == 429
  end

  def possible_request?
    found? && !@console.nil? && !@overlimited ? true : false
  end
end
