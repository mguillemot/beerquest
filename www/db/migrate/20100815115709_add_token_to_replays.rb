class AddTokenToReplays < ActiveRecord::Migration
  def self.up
		add_column :replays, :token, :string
		add_column :replays, :token_use_time, :datetime
		add_column :replays, :ip, :string
  end

  def self.down
  end
end
