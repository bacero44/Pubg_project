# frozen_string_literal: true

require 'httparty'

# Class to consume Api
class Pubg
  attr_reader :id


  def initialize(console = nil, player_name = nil, id = nil)
    @id = id
    @console = console
    player_id(console, player_name) if id.nil?
  end

  def stats
    !@id.nil? ? lifetime : false
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
    unless @id.nil? && @console.nil?
      r = request("https://api.pubg.com/shards/#{@console}/players/#{@id}/seasons/lifetime")
      case r.code
      when 200
        r['data']['attributes']['gameModeStats']
      else
        error_details(r)
        false
      end
    end
  end

  def season_stats
    season_id = current_season
    if !@id.nil? && !@console.nil? && season_id
      r = request("https://api.pubg.com/shards/#{@console}/players/#{@id}/seasons/#{season_id}")
      case r.code
      when 200
        r['data']['attributes']['gameModeStats']
      else
        error_details(r)
        false
      end
    else
      false
    end
  end

  def current_season
    redis = Redis.get_current_season(@console)
    if redis && ((Time.now - Time.parse(redis['date'].to_s)) < 43_200)
      redis['id']
    else
      r = request("https://api.pubg.com/shards/#{@console}/seasons")
      if r.code == 200
        id = r['data'].find { |x| x['attributes']['isCurrentSeason'] }['id']
        Redis.save_current_season(@console, id)
        id
      else
        error_details(r)
        false
      end
    end
    
  end

  private

  # generic API's request
  def request(url)
    puts "Entra al request--FROM: #{caller_locations(1,1)[0].label} --!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! "
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
