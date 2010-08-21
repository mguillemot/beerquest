class RemoveScores < ActiveRecord::Migration
  def self.up
    drop_table :scores
  end

  def self.down
  end
end
