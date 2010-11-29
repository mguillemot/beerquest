class WallPost
  include DataMapper::Resource

  property :id, Serial
  property :replay_id, Integer, :min => 1, :required => true
  property :post_id, Integer, :min => 0, :max => 2**64-1
  property :from_location, String, :length => 255
  property :created_at, DateTime
  property :updated_at, DateTime

end
