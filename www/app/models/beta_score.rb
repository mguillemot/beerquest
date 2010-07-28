class BetaScore < ActiveRecord::Base
	belongs_to :account

	def self.high_scores(me = nil)
		scores = []
		all(:group => "account_id", :order => "score DESC", :limit => 5, :include => :account).each_with_index do |s, i|
			scores.push({
													:firstName => s.account.first_name,
													:lastName => s.account.last_name,
													:avatar => s.account.avatar,
													:score => s.score,
													:rank => (i+1),
													:me => (s.account_id == me)
									})
		end
		scores
	end
end
