class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
			t.string 'login', :limit => 32, :null => false
			t.string 'password', :limit => 32
			t.string 'email', :limit => 128
      t.timestamps
    end
  end

  def self.down
    drop_table :accounts
  end
end
