class Barship
  include DataMapper::Resource

  property :account_id, Integer, :key => true
  property :bar_id, Integer, :key => true
  property :play_count, Integer
  property :last_play, DateTime
  property :total_beers, Integer
  property :max_score, Integer
  property :created_at, DateTime
  property :updated_at, DateTime

  belongs_to :account
  belongs_to :bar
end
