class BetaScoreToReplay < ActiveRecord::Migration
  def self.up
    rename_table :beta_scores, :replays
  end

  def self.down
  end
end
