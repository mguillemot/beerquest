class Invite
  include DataMapper::Resource

  property :id, Serial
  property :account_id, Integer, :min => 1, :required => true, :index => true # Note: required declaration to have NULLable FK
  property :request_id, Integer, :min => 0, :max => 2**64-1, :required => true, :index => true
  property :message, Integer
  property :lang, String
  property :created_at, DateTime
  property :updated_at, DateTime

  belongs_to :account

end
