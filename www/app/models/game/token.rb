module Game
  class Token

    NONE = " "
    BLOND_BEER = "b"
    BROWN_BEER = "r"
    AMBER_BEER = "a"
    WATER = "w"
    FOOD = "f"
    LIQUOR = "l"
    TOMATO_JUICE = "t"
    TRIPLE = "*"
    VOMIT = "v"

    def self.compatible?(t1, t2)
      t1.downcase!
      t2.downcase!
      (t1 == t2 || t1 == TRIPLE || t2 == TRIPLE)
    end

    def self.same?(t1, t2)
      t1.downcase!
      t2.downcase!
      (t1 == t2)
    end

  end
end

class String
  def super?
    (self == self.upcase)
  end

  def collectible?
    /^[brawflt]$/i =~ self
  end
end