class World

  def self.total_beers
    Replay.finished.sum(:score) || 0
  end

end