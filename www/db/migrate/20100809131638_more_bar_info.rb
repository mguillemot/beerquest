class MoreBarInfo < ActiveRecord::Migration
  def self.up
		add_column :bars, :location, :string, :null => false
		add_column :bars, :banner, :string, :null => false
		add_column :bars, :contact, :string
		add_column :bars, :total_plays, :integer, :null => false, :default => 0
		add_column :bars, :total_beers, :decimal, :precision => 15, :scale => 0, :null => false, :default => 0
  end

  def self.down
  end
end
