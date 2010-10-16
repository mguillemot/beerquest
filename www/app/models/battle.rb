class Battle
  include DataMapper::Resource

  property :id, Serial
  is :tree
  property :account_id, Integer, :min => 1
  property :friend_id, Integer, :min => 1
  property :replay_id, Integer, :min => 1
  property :required_score, Integer
  property :created_at, DateTime
  property :updated_at, DateTime

  belongs_to :account
  belongs_to :friend, :model => Account
  belongs_to :replay

end
