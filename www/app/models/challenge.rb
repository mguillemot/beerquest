class Challenge
  include DataMapper::Resource

  property :id, Serial
  is :tree, :order => :created_at
  property :account_id, Integer, :min => 1
  property :sent_by_id, Integer, :min => 1
  property :required_score, Integer
  property :replay_id, Integer, :min => 1
  property :replay_score, Integer
  property :created_at, DateTime
  property :updated_at, DateTime

  belongs_to :account
  belongs_to :sent_by, :model => Account
  belongs_to :replay

  def new?
    (parent_id == nil)
  end

end
