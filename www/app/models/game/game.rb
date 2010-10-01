module Game
  class Game


    def initialize(seed)
      @board = Board.new(seed, Proc.new { |g| collect(g) })
      @score = 0
      @collection = []
      @capacities = []
      @piss = 0
      @vomit = 0
      @remaining_turns = Constants::INITIAL_TURNS
    end

    def swap_cells(source, destination)
      @board.swap_cells(source, destination)
      skip_turns(1)
    end

    def add_collected_token(token)
      @collection.push(token)
      if @collection.length >= 3 && Token.compatible?(@collection[-1], @collection[-2]) && Token.compatible?(@collection[-2], @collection[-3])
        @score += 5
        @collection[-3..-1] = nil
      end
      excess = 12 - @collection.length + collection_head
      if excess > 0
        excess.times { @collection.pop }
      end
    end

    def piss
      @piss
    end

    def piss=(value)
      if value < 0
        value = 0
      elsif value > 100
        value = 100
      end
      @piss = value
      if value >= 90
        @board.pisslevel = 3
      elsif value >= 80
        @board.pisslevel = 2
      elsif value >= 70
        @board.pisslevel = 1
      else
        @board.pisslevel = 0
      end
    end

    def do_piss
      self.piss = self.piss * 0.4
    end

    def vomit
      @vomit
    end

    def vomit=(value)
      if value < 0
        value = 0
      elsif value > 100
        @board.create_vomit(5)
        value = 30
      end
      @vomit = value
    end

    def execute_capacity(capacity, param)
      case capacity
        when Capacity::DIVINE_PEANUTS
          @board.transform_tokens_of_type(Token::LIQUOR, Token::WATER)
        when Capacity::WATERFALL
          @board.destroy_tokens_of_type(Token::VOMIT)
        when Capacity::BIG_BANG
          @board.destroy_tokens_of_type(param)
        when Capacity::BLOND_FURY_BAR
          @score += @board.destroy_tokens_of_type(Token::BLOND_BEER)
        when Capacity::BROWN_FURY_BAR
          @score += @board.destroy_tokens_of_type(Token::BROWN_BEER)
        when Capacity::AMBER_FURY_BAR
          @score += @board.destroy_tokens_of_type(Token::AMBER_BEER)
        when Capacity::BLOODY_MARY
          @remaining_turns += 6
          @board.create_vomit(3)
      end
      if @capacities[0] == capacity
        @capacities[0] = nil
      elsif @capacities[1] == capacity
        @capacities[1] = nil
      end
    end

    private

    def gain_capacity(capacity)
      if @capacities.length < 2
        @capacities.push(capacity)
      end
    end

    def collection_head
      if @collection.length <= 1
        @collection.length
      elsif Token.compatible?(@collection[-1], @collection[-2])
        2
      else
        1
      end
    end

    def preferred_token
      if @collection.empty?
        Token::NONE
      elsif @collection.length == 1
        @collection[0]
      elsif @collection[-1] == Token::TRIPLE
        @collection[-2]
      else
        @collection[-1]
      end
    end

    def flush_board
      @board.generate_random_keeping_some_vomit
      skip_turns(3)
    end

    def skip_turns(turns)
      @remaining_turns -= turns
      # TODO game over
    end

    def normalize_board
      @board.normalize
      if @board.moves.empty?
        @board.generate_random_keeping_some_vomit
      end
    end

    def collect(group)
      if group.collected_token
        add_collected_token(group.collected_token)
      end
      @piss += group.piss_gain
      @vomit += group.vomit_gain
      @remaining_turns += group.turns_gain
      @score += group.score_gain
    end

  end
end