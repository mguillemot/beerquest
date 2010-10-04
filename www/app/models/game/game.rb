module Game
  class Game

    def initialize
      @score = 0
      @collection = []
      @capacities = []
      @piss = 0
      @vomit = 0
      @remaining_turns = Constants::INITIAL_TURNS
    end

    attr_reader :board, :score, :collection, :capacities, :remaining_turns

    def start(seed)
      @board = Board.new(seed, Proc.new { |groups| collect(groups) })
      @board.generate_random_without_groups
    end

    def dup
      result = Game.new
      result.board = @board.dup
      result.score = @score
      result.collection = @collection.dup
      result.capacities = @capacities.dup
      result.piss = @piss
      result.vomit = @vomit
      result.remaining_turns = @remaining_turns
      result
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
      excess = @collection.length - collection_head - 12
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
      if value >= 100
        @board.pisslevel = 3
      elsif value >= 90
        @board.pisslevel = 2
      elsif value >= 80
        @board.pisslevel = 1
      else
        @board.pisslevel = 0
      end
    end

    def do_piss
      self.piss *= 0.4
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
        when Token::FOOD
          @board.transform_tokens_of_type(Token::LIQUOR, Token::WATER)
        when Token::WATER
          @board.destroy_tokens_of_type(Token::VOMIT)
        when Token::LIQUOR
          @board.destroy_tokens_of_type(param)
        when Token::BLOND_BEER
          @score += @board.destroy_tokens_of_type(Token::BLOND_BEER)
        when Token::BROWN_BEER
          @score += @board.destroy_tokens_of_type(Token::BROWN_BEER)
        when Token::AMBER_BEER
          @score += @board.destroy_tokens_of_type(Token::AMBER_BEER)
        when Token::TOMATO_JUICE
          @remaining_turns += 6
          @board.create_vomit(3)
      end
      if @capacities[0] == capacity
        @capacities[0..0] = nil
      elsif @capacities[1] == capacity
        @capacities[1..1] = nil
      end
    end

    def skip_turns(turns)
      @remaining_turns -= turns
      # TODO game over
    end

    protected

    attr_writer :board, :score, :collection, :capacities, :remaining_turns

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

    def normalize_board
      @board.normalize
      if @board.moves.empty?
        @board.generate_random_keeping_some_vomit
      end
    end

    def collect(groups)
      tokens = []
      groups.each do |group|
        tokens.push(group.collected_token) if group.collected_token
        self.piss += group.piss_gain
        self.vomit += group.vomit_gain
        self.remaining_turns += group.turns_gain
        self.score += group.score_gain
        gain_capacity(group.token) if group.length >= 4
      end

      # Reorder collected tokens
      until tokens.empty?
        preferred = self.preferred_token
        found = false
        kept = []
        tokens.each_with_index do |token, i|
          if Token.compatible?(token, preferred)
            add_collected_token(token)
            found = true
          else
            kept.push(token)
          end
        end
        if found
          tokens = kept
        else
          add_collected_token(tokens.pop)
        end
      end
    end

  end
end