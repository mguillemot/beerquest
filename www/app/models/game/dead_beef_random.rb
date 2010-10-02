module Game
  class DeadBeefRandom

    def initialize(seed)
      @seed = seed
      @beef = 0xDEADBEEF
    end

    def next
      a = (@seed << 7) & 0xFFFFFFFF
      b = (@seed >> 25) & 0xFFFFFFFF
      c = (b + @beef) & 0xFFFFFFFF
      @seed = (a ^ c) & 0xFFFFFFFF
      d = (@beef << 7) & 0xFFFFFFFF
      e = (@beef >> 25) & 0xFFFFFFFF
      f = (e + 0xDEADBEEF) & 0xFFFFFFFF
	  @beef = (d ^ f) & 0xFFFFFFFF
	  @seed
    end

    def next_int(min, max)
      min + (self.next % (max - min + 1)).floor
    end

  end
end