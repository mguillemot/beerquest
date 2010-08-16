class AddGameOverToReplays < ActiveRecord::Migration
  def self.up
		add_column :replays, :game_over, :boolean
		remove_column :replays, :multiplier_count
		remove_column :replays, :max_multiplier
  end

  def self.down
  end
end
