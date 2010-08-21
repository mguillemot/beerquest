class CorrectStats < ActiveRecord::Migration
  def self.up
    change_column :beta_scores, :play_time, :integer
    change_column :beta_scores, :avg_combo, :decimal, :precision => 10, :scale => 3
    change_column :beta_scores, :avg_groups_per_turn, :decimal, :precision => 10, :scale => 3
    change_column :beta_scores, :avg_piss_level, :decimal, :precision => 10, :scale => 3
    change_column :beta_scores, :avg_time_per_turn, :decimal, :precision => 10, :scale => 3
    change_column :beta_scores, :avg_vomit, :decimal, :precision => 10, :scale => 3
    remove_column :beta_scores, :max_groups_per_turn
    remove_column :beta_scores, :avg_groups_per_turn
  end

  def self.down
  end
end
