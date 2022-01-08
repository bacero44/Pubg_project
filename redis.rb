# frozen_string_literal: true

require 'rejson'
REDIS = Redis.new({ password: ENV["REDIS_PASS"] })

# Redis class
class RedisCache
  class << self
    def active?
      a = true
      begin
        REDIS.ping
      rescue 
        a = false
      end
      a
    end

    def get_player(console, player_name)
      return false unless active?

      r = REDIS.json_get "#{console}-#{player_name}", Rejson::Path.root_path
      if !r.nil?
        stats_format(r['id'], r['player_name'], r['console'], r['stats'], r['season'], DateTime.parse(r['date']))
      else
        false
      end
    end

    def save_player(console, player_name, id, stats, season)
      return false unless active?

      REDIS.json_set(
        "#{console}-#{player_name}",
        Rejson::Path.root_path, stats_format(id, player_name, console, stats, season, Time.new)
      )
    end

    def save_current_season(console, id)
      return false unless active?

      REDIS.json_set("current_season-#{console}", Rejson::Path.root_path,  season_format(id, Time.new))
    end

    def get_current_season(console)
      return false unless active?

      r = REDIS.json_get "current_season-#{console}", Rejson::Path.root_path
      if !r.nil?
        season_format(r['id'], DateTime.parse(r['date']))
      else
        false
      end
    end

    private

    def stats_format(id, player_name, console, stats, season, date)
      {
        'id' => id,
        'player_name' => player_name,
        'console' => console,
        'stats' => stats,
        'season' => season,
        'date' => date
      }
    end

    def season_format(id, date)
      {
        'id' => id,
        'date' => date
      }
    end
  end
end
