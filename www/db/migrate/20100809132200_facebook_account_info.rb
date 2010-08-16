class FacebookAccountInfo < ActiveRecord::Migration
  def self.up
		add_column :accounts, :facebook_id, :string
		add_column :accounts, :gender, :string
		add_column :accounts, :locale, :string
		add_column :accounts, :timezone, :integer
		add_column :accounts, :login_count, :integer, :null => false, :default => 0
		add_column :accounts, :last_login, :datetime
		add_column :accounts, :discovered_through, :integer
		rename_column :accounts, :avatar, :profile_picture
		remove_column :accounts, :password
		remove_column :accounts, :login
		remove_column :accounts, :level
		remove_column :accounts, :total_play
		remove_column :accounts, :last_play
		remove_column :accounts, :play_count
		add_index :accounts, :facebook_id
  end

  def self.down
  end
end
