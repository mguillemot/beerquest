class Friendship
  include DataMapper::Resource

  property :account_id, Integer, :key => true
  property :friend_id, Integer, :key => true
  property :created_at, DateTime
  property :updated_at, DateTime

  belongs_to :account
  belongs_to :friend, :model => Account
end
