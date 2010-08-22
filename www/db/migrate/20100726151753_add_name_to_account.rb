class AddNameToAccount < ActiveRecord::Migration
  def self.up
    add_column :accounts, :first_name, :string
    add_column :accounts, :last_name, :string
    add_column :accounts, :avatar, :string
    add_column :accounts, :play_count, :integer, :null => false, :default => 0
    add_column :accounts, :total_play, :timestamp, :null => false, :default => 0
    add_column :accounts, :last_play, :datetime
  end

  def self.down
  end
end
