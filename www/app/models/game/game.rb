module Game
  class Game

    INITIAL_TURNS = 50

    def initialize(seed)
      @board = Board.new(seed)
      @score = 0
      @capacities = []
      @piss = 0
      @vomit = 0
      @remaining_turns = INITIAL_TURNS
    end

  end
end