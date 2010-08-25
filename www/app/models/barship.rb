class Barship
  include DataMapper::Resource

  property :account_id, Integer, :min => 1, :key => true # Note 1: these 2 properties are necessary besides the belongs_to declarations to declare the composite key
  property :bar_id, Integer, :min => 1, :key => true     # Note 2: :min => 1 is necessary to have UNSIGNED INT to reference the column as FK
  property :play_count, Integer
  property :last_play, DateTime
  property :total_beers, Integer
  property :max_score, Integer
  property :created_at, DateTime
  property :updated_at, DateTime

  belongs_to :account
  belongs_to :bar
end
