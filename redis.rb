# frozen_string_literal: true

require 'rejson'
REDIS = Redis.new({ password: ENV["REDIS_PASS"] })

# Redis class
class Redis
  class << self
    def get_player(console, player_name)
      r = REDIS.json_get "#{console}-#{player_name}", Rejson::Path.root_path
      if !r.nil?
        {
          'date' => DateTime.parse(r['date']),
          'id' => r['id'],
          'stats' => r['stats'],
          'season' => r['season'],
          'player_name' => r['player_name'],
          'console' => r['console']
        }
      else
        false
      end
    end

    def save_player(console, player_name, id, stats, season)
      REDIS.json_set("#{console}-#{player_name}", Rejson::Path.root_path, {
        'player_name' => player_name,
        'console' => console,
        'id' => id, 
        'stats' => stats,
        'season' => season,
        'date' => Time.new
      })
    end

    def save_current_season(console, id)
      REDIS.json_set("current_season-#{console}", Rejson::Path.root_path, {
        'id' => id,
        'date' => Time.new
      })
    end

    def get_current_season(console)
      r = REDIS.json_get "current_season-#{console}", Rejson::Path.root_path
      if !r.nil?
        {
          'date' => DateTime.parse(r['date']),
          'id' => r['id']
        }
      else
        false
      end
    end
  end
end