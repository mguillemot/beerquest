class AddSeed < ActiveRecord::Migration
  def self.up
    add_column :replays, :seed, :integer
  end

  def self.down
  end
end
