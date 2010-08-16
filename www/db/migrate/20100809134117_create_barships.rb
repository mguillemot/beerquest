class CreateBarships < ActiveRecord::Migration
  def self.up
    create_table :barships do |t|
			t.integer :account_id, :null => false
			t.integer :bar_id, :null => false
			t.integer :play_count, :null => false, :default => 0
			t.datetime:last_play
			t.integer :total_beers, :null => false, :default => 0
			t.integer :max_beers, :null => false, :default => 0
      t.timestamps
		end
		add_index :barships, :account_id
		add_index :barships, :bar_id
  end

  def self.down
    drop_table :barships
  end
end
