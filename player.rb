# frozen_string_literal: true

#Class for Player attributes
class Player
  attr_reader :console, :player_name, :id, :stats, :season_stats

  def initialize(console = 'xbox', player_name = 'Bacero44', id = nil)
    @player_name = player_name
    @console = console
    @id = id
    @pubg = Pubg.new(@console, @player_name, @id)
    @id = @pubg.id
    @stats = format_stats(@pubg.stats)
    @season_stats = format_stats(@pubg.season_stats)
  end


  def save
    Redis.save_player(@console, @player_name, @id, @stats, @season_stats) if found?
  end

  def found?
    @pubg.id.nil? ? false : true
  end

  private

  def format_stats(stats)
    rounds = stats.sum { |s| s[1]['roundsPlayed'] }
    kills = stats.sum { |s| s[1]['kills'] }
    wins = stats.sum { |s| s[1]['wins'] }
    kd = (kills.to_f / rounds).round(3)
    {
      'rounds' => rounds,
      'kills' => kills,
      'wins' => wins,
      'kd' => kd
    }
  end

  def stats_refresh
    @pubg.lifetime
  end

end