class Replay < ActiveRecord::Base
	belongs_to :account

	def self.high_scores(me = nil)
		scores = []
		find_by_sql("SELECT MAX(score) AS score, account_id FROM #{table_name} GROUP BY account_id ORDER BY score DESC LIMIT 5").each_with_index do |s, i|
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
