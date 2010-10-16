class World

  def self.total_beers
    Replay.finished.sum(:score) || 0
  end

  def self.increase_last_hour
    Replay.finished.all(:created_at.gte => DateTime.now - 1.hour).sum(:score) || 0
  end

end