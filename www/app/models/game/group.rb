module Game
  class Group

    attr_accessor :x, :y, :direction, :length, :token, :supers

    def initialize(x, y, direction, length, token, supers)
      @x = x
      @y = y
      @direction = direction
      @length = length
      @token = token
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

  end
end