class Account < ActiveRecord::Base
	has_many :friendships
	has_many :friends, :through => :friendships
	has_many :replays
	has_many :barships
	has_many :bars, :through => :barships

	def full_name
		"#{first_name} #{last_name}"
	end

	def total_beers
		barships.sum(:total_beers)
	end

	def max_beers
		barships.maximum(:max_beers)
	end

	def play_count
		barships.sum(:play_count)
	end
end
