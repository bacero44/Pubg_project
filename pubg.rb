# frozen_string_literal: true

require 'httparty'
# Class to consume Api
class Pubg
  attr_reader :id

  @@key = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJqdGkiOiJlN2Y4ZGEyMC0wNDkxLTAxMzktMzJiOC0wYjFmZmJmMzZjY2YiLCJpc3MiOiJnYW1lbG9ja2VyIiwiaWF0IjoxNjA0OTA5ODM4LCJwdWIiOiJibHVlaG9sZSIsInRpdGxlIjoicHViZyIsImFwcCI6InB1Ymc0NCJ9.rC4pA6cQ9b_CcoM4oFMm66OYgAhrpIvv583A6xTurAU'

  @stats = nil
  @id = nil

  def stats
    lifetime if !@id.nil? && @stats.nil?
    @stats
  end

  def current_id(id)
    @id = id
    lifetime if !@id.nil? && @stats.nil?
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
    #puts 'Entra al request-----------------------!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
    HTTParty.get(url, headers: {
      'Content-Type' => 'application/json',
      'accept' => 'application/vnd.api+json',
      'Authorization' => " Bearer #{@@key}"
    })
  end

  # Error method
  def error_details(_data)
    # TODO: Create handle to errors
  end
end
