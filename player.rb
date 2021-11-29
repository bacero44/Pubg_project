# frozen_string_literal: true

#Class for Player attributes
class Player
  attr_reader :console, :player_name, :id

  def initialize(console = 'xbox', player_name = 'Bacero44', id = nil)
    @player_name = player_name
    @console = console
    @id = id
    @pubg = Pubg.new(@console, @player_name, @id)
  end

  def stats
    if found?
      rounds = @pubg.stats.sum { |s| s[1]['roundsPlayed'] }
      kills = @pubg.stats.sum { |s| s[1]['kills'] }
      wins =  @pubg.stats.sum { |s| s[1]['wins'] }
      kd = (kills.to_f / rounds).round(3)
      {
        "rounds": rounds,
        "kills": kills,
        "wins": wins,
        "kd": kd
      }
    end
  end

  def found?
    @pubg.id.nil? ? false : true
  end

  private

  def stats_refresh
    @pubg.lifetime
  end

end