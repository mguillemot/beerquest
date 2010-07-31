class AddStatsAboutStack < ActiveRecord::Migration
  def self.up
		add_column :beta_scores, :stack_ejected, :integer
		add_column :beta_scores, :stack_collected, :integer
  end

  def self.down
  end
end
