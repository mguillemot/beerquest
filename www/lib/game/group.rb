module Game
  class Group

    attr_accessor :x, :y, :direction, :length, :token, :supers

    def initialize(x, y, direction, length, token, supers)
      @x = x
      @y = y
      @direction = direction
      @length = length
      @token = token.downcase
      @supers = supers
    end

    def each_cell
      (0...@length).each do |k|
        i = @x
        j = @y
        if @direction == "horizontal"
          i += k
        else
          j += k
        end
        yield i, j
      end
    end

    def midx
      (@x + @length / 2).floor
    end

    def midy
      (@y + @length / 2).floor
    end

    def collected_token
      if @token == Token::BLOND_BEER || @token == Token::BROWN_BEER || @token == Token::AMBER_BEER
        (@length >= 4) ? Token::TRIPLE : @token
      else
        nil
      end
    end

    def score_gain
      result = @supers * Constants::SUPER_TOKEN_VALUE
      if @token == Token::BLOND_BEER || @token == Token::BROWN_BEER || @token == Token::AMBER_BEER
        result += @length
      end
      result
    end

    def turns_gain
      (@token == Token::TOMATO_JUICE) ? 1 : 0
    end

    def piss_gain
      if @token == Token::BLOND_BEER || @token == Token::BROWN_BEER || @token == Token::AMBER_BEER || @token == Token::WATER
        3 * @length
      else
        0
      end
    end

    def vomit_gain
      if @token == Token::BLOND_BEER || @token == Token::BROWN_BEER || @token == Token::AMBER_BEER
        3 * @length
      elsif @token == Token::LIQUOR
        6 * @length
      elsif @token == Token::FOOD
        -7 * @length
      else
        0
      end
    end

  end
end