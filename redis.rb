# frozen_string_literal: true

require 'rejson'
REDIS = Redis.new({ password: ENV["REDIS_PASS"] })

# Redis class
class Redis
  class << self
    def get_player(console, player_name)
      r = REDIS.json_get "#{console}-#{player_name}", Rejson::Path.root_path
      unless r.nil?
        {
          'date' => DateTime.parse(r['date']),
          'id' => r['id'],
          'stats' => r['stats'],
          'player_name' => r['player_name'],
          'console' => r['console']
        }
      else
        false
      end
    end

    def save_player(console, player_name, id, payload)
      REDIS.json_set("#{console}-#{player_name}", Rejson::Path.root_path, {
        'player_name' => player_name,
        'console' => console,
        'id' => id, 
        'stats' => payload,
        'date' => Time.new
      })
    end
  end
end