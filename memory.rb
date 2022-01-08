# frozen_string_literal: true

MEMORY = {}
# Memory class
class MemoryCache
  class << self
    def get_player(console, player_name)
      m = MEMORY[:"#{console}-#{player_name}"]
      if !m.nil?
        stats_format(m['id'], m['player_name'], m['console'], m['stats'], m['season'], m['date'])
      else
        false
      end
    end

    def save_player(console, player_name, id, stats, season)
      MEMORY[:"#{console}-#{player_name}"] = stats_format(id, player_name, console, stats, season, Time.new)
    end

    def save_current_season(console, id)
      MEMORY[:"current_season-#{console}"] = season_format(id, Time.new)
    end

    def get_current_season(console)
      s = MEMORY[:"current_season-#{console}"]
      if !s.nil?
        season_format(s['id'], s['date'])
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
