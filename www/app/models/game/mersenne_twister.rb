module Game
  class MersenneTwister

    def initialize(seed)
      @mt = []
      624.times { @mt.push(0) }
      @initial_seed = @mt[0] = seed
      (1...623).each do |i|
        @mt[i] = (1812433253 * (@mt[i - 1] ^ (@mt[i - 1] >> 30)) + 1) & 0xFFFFFFFF
      end
      @y = @z = 0
    end

    def next
      if @z == 0
        generate_numbers
      end
      @y = @mt[@z]
      @y ^= (@y >> 11)
      @y ^= (@y << 7) & 0x9d2c5680
      @y ^= (@y << 15) & 0xefc60000
      @y ^= (@y >> 18)
      @z = (@z + 1) % 624
      @y
    end

    def next_int(min, max)
      min + (self.next % (max - min + 1)).floor
    end

    private

    def generate_numbers
      (0..623).each do |i|
        @y = 0x80000000 & @mt[i] + 0x7FFFFFFF & (@mt[(i + 1) % 624])
        @mt[i] = @mt[(i + 397) % 624] ^ (@y >> 1)
        if (@y % 2) == 1
          @mt[i] = @mt[i] ^ 2567483615
        end
      end
    end

  end
end