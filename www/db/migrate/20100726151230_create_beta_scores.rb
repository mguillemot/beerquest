class CreateBetaScores < ActiveRecord::Migration
  def self.up
    create_table :beta_scores do |t|
      t.string :first_name
      t.string :last_name
      t.string :avatar
      t.integer :score
      t.timestamps
    end
  end

  def self.down
    drop_table :beta_scores
  end
end
