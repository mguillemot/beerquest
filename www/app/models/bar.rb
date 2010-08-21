class Bar < ActiveRecord::Base
  has_many :barships
  has_many :accounts, :through => :barships

  def high_scores(me = nil)
    scores = []
    barships.order('max_beers DESC').limit(5).each_with_index do |bs, i|
      scores.push({
                          :firstName => bs.account.first_name,
                          :lastName => bs.account.last_name,
                          :profile_picture => bs.account.profile_picture,
                          :score => bs.max_beers,
                          :rank => (i+1),
                          :me => (bs.account_id == me)
                  })
    end
    scores
  end
end
