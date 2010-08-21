class LinkBetweenAccountAndBetaScore < ActiveRecord::Migration
  def self.up
    remove_columns :beta_scores, :first_name, :last_name, :avatar
    add_column :beta_scores, :account_id, :integer, :null => false
  end

  def self.down
  end
end
