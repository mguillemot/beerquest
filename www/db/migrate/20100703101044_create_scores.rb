class CreateScores < ActiveRecord::Migration
  def self.up
    create_table :scores do |t|
			t.integer 'user_id', :null => false
			t.integer 'bar_id'
			t.integer 'score', :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :scores
  end
end
