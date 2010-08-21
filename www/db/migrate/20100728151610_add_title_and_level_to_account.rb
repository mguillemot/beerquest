class AddTitleAndLevelToAccount < ActiveRecord::Migration
  def self.up
    add_column :accounts, :title, :string, :null => false
    add_column :accounts, :level, :integer, :default => 0, :null => false
  end

  def self.down
  end
end
