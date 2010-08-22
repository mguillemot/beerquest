class FacebookIdBigint < ActiveRecord::Migration
  def self.up
    remove_column :accounts, :facebook_id
    add_column :accounts, :facebook_id, :integer, :limit => 8
  end

  def self.down
  end
end
