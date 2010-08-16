class AddIndexToReplays < ActiveRecord::Migration
  def self.up
		add_index :replays, :account_id
  end

  def self.down
  end
end
