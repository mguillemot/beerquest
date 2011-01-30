class Invite
  include DataMapper::Resource

  property :id, Serial
  property :account_id, Integer, :min => 1, :required => true, :index => true # Note: required declaration to have NULLable FK
  property :request_id, Integer, :min => 0, :max => 2**64-1, :required => true, :index => true
  property :lang, String
  property :data, String, :length => 0..255
  property :message, String, :length => 0..255
  property :friend_facebook_id, Integer, :min => 0, :max => 2**64-1, :required => true, :index => true
  property :friend_name, String, :length => 0..255
  property :accepted_by, Integer, :min => 1 # TODO ajouter l'association
  property :accepted_at, DateTime
  property :created_at, DateTime
  property :updated_at, DateTime

  belongs_to :account

end
