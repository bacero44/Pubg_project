# frozen_string_literal: true

# Class for Player attributes
class Player
  attr_reader :console, :player_name, :stats, :season_stats, :error

  def initialize(console = 'xbox', player_name = 'Bacero44')
    @player_name = player_name
    @console = console
    @date_cache = nil
    @id = nil
    @stats = nil
    @season_stats = nil
    @error = false
    starter
  end

  def found?
    [@id, @stats, @season_stats].none?(&:nil?)
  end

  private

  def starter
    data_origin if !cache && !valid_lapse_cache?
  end

  def cache
    cache = CACHE.get_player(@console, @player_name)
    if cache
      fill(cache['id'], cache['stats'], cache['season'])
      true
    else
      false
    end
  end

  def data_origin
    data = Pubg.new(@console, @player_name, @id)
    if data.found? && !data.overlimited?
      fill(data.id, format_stats(data.stats), format_stats(data.season_stats)) 
      save
      true
    else
      @error = true if data.overlimited?
      false
    end
  end

  def fill(id, stats, season_stats, date = nil)
    @id = id
    @stats = stats
    @season_stats = season_stats
    @date_cache = date
  end

  def valid_lapse_cache?
    @date.nil? ? false : Time.now - Time.parse(@date.to_s) < REFRESHMENT_TIME
  end

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

  def save
    if found?
      CACHE.save_player(@console, @player_name, @id, @stats, @season_stats) ? true : false
    else
      false
    end
  end
end
