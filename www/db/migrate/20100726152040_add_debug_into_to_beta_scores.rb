class AddDebugIntoToBetaScores < ActiveRecord::Migration
  def self.up
		add_column :beta_scores, :mode, :string
		add_column :beta_scores, :game_version, :string
		add_column :beta_scores, :caps, :integer
		add_column :beta_scores, :play_time, :timestamp
		add_column :beta_scores, :avg_time_per_turn, :decimal, :precision => 5, :scale => 2
		add_column :beta_scores, :total_turns, :integer
		add_column :beta_scores, :replay, :text
		add_column :beta_scores, :collected_blond, :integer
		add_column :beta_scores, :collected_brown, :integer
		add_column :beta_scores, :collected_amber, :integer
		add_column :beta_scores, :collected_food, :integer
		add_column :beta_scores, :collected_water, :integer
		add_column :beta_scores, :collected_liquor, :integer
		add_column :beta_scores, :collected_coaster, :integer
		add_column :beta_scores, :collected_tomato, :integer
		add_column :beta_scores, :max_groups_per_turn, :integer
		add_column :beta_scores, :avg_groups_per_turn, :decimal, :precision => 5, :scale => 2
		add_column :beta_scores, :max_group_size, :integer
		add_column :beta_scores, :groups_3, :integer
		add_column :beta_scores, :groups_4, :integer
		add_column :beta_scores, :groups_5, :integer
		add_column :beta_scores, :multiplier_count, :integer
		add_column :beta_scores, :max_multiplier, :integer
		add_column :beta_scores, :max_combo, :integer
		add_column :beta_scores, :avg_combo, :decimal, :precision => 5, :scale => 2
		add_column :beta_scores, :capa_blond_gained, :integer
		add_column :beta_scores, :capa_blond_used, :integer
		add_column :beta_scores, :capa_brown_gained, :integer
		add_column :beta_scores, :capa_brown_used, :integer
		add_column :beta_scores, :capa_amber_gained, :integer
		add_column :beta_scores, :capa_amber_used, :integer
		add_column :beta_scores, :capa_food_gained, :integer
		add_column :beta_scores, :capa_food_used, :integer
		add_column :beta_scores, :capa_water_gained, :integer
		add_column :beta_scores, :capa_water_used, :integer
		add_column :beta_scores, :capa_liquor_gained, :integer
		add_column :beta_scores, :capa_liquor_used, :integer
		add_column :beta_scores, :capa_tomato_gained, :integer
		add_column :beta_scores, :capa_tomato_used, :integer
		add_column :beta_scores, :capa_coaster_gained, :integer
		add_column :beta_scores, :capa_coaster_used, :integer
		add_column :beta_scores, :piss_count, :integer
		add_column :beta_scores, :vomit_count, :integer       
		add_column :beta_scores, :reset_count, :integer
		add_column :beta_scores, :max_piss_level, :integer
		add_column :beta_scores, :avg_piss_level, :decimal, :precision => 5, :scale => 2
		add_column :beta_scores, :max_vomit, :integer
		add_column :beta_scores, :avg_vomit, :decimal, :precision => 5, :scale => 2
		add_column :beta_scores, :invalid_moves, :integer
		add_column :beta_scores, :user_agent, :string
		add_column :beta_scores, :flash_version, :string
  end

  def self.down
  end
end
