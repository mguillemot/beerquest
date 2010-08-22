class RemoveTitleFromAccount < ActiveRecord::Migration
  def self.up
    remove_column :accounts, :title
  end

  def self.down
  end
end
