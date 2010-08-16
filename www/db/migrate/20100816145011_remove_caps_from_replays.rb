class RemoveCapsFromReplays < ActiveRecord::Migration
  def self.up
		remove_column :replays, :caps
		remove_column :replays, :capa_coaster_gained
		remove_column :replays, :capa_coaster_used
		add_column :replays, :update_count, :integer, :null => false, :default => 0
  end

  def self.down
  end
end
