module Game
  class Capacity

    BLOND_FURY_BAR = Capacity.new(Token::BLOND_BEER)
    BROWN_FURY_BAR = Capacity.new(Token::BROWN_BEER)
    AMBER_FURY_BAR = Capacity.new(Token::AMBER_BEER)
    DIVINE_PEANUTS = Capacity.new(Token::FOOD)
    BIG_BANG = Capacity.new(Token::LIQUOR)
    WATERFALL = Capacity.new(Token::WATER)
    BLOODY_MARY = Capacity.new(Token::TOMATO_JUICE)

    private

    def initialize(type)
      @type = type
    end

  end
end