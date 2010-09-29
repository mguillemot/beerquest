module Game
  class Board

    SIZE = 8

    attr_accessor :pisslevel

    def initialize
      @cells = Token::NONE * (SIZE * SIZE)
      @pisslevel = 0
    end

    def decode(encoded_board)
      @cells = encoded_board
    end

    def [](i, j)
      @cells[i * SIZE + j].chr
    end

    def []=(i, j, v)
      @cells[i * SIZE + j] = v
    end

    def dump
      result = ""
      (0...SIZE).each do |i|
        (0...SIZE).each do |j|
          result << self[i, j]
        end
        result << "\n"
      end
      result
    end

    def groups
      groups = []

      # Check for horizontal groups
      i = j = 0
      while j < SIZE
        while i < SIZE - 2
          token = self[i, j]
          if token.collectible?
            di = 0
            supers = 0
            while i + di < SIZE && Token.same?(token, self[i + di, j])
              if self[i + di, j].super?
                supers += 1
              end
              di += 1
            end
            if di >= 3
              groups.push(Group.new(i, j, "horizontal", di, token.downcase, supers))
            end
            i += di - 1
          end
          i += 1
        end
        j += 1
      end

      # Check for horizontal groups
      i = j = 0
      while i < SIZE
        while j < SIZE - 2
          token = self[i, j]
          if token.collectible?
            dj = 0
            supers = 0
            while j + dj < SIZE && Token.same?(token, self[i, j + dj])
              if self[i, j + dj].super?
                supers += 1
              end
              dj += 1
            end
            if dj >= 3
              groups.push(Group.new(i, j, "vertical", dj, token.downcase, supers))
            end
            j += dj - 1
          end
          j += 1
        end
        i += 1
      end

      groups
    end

    def groups?
      (groups.length > 0)
    end

    def moves(piss = true)
      moves = []
      pisslevel = piss ? @pisslevel : 0

      # Check for horizontal moves
      (0...SIZE-pisslevel).each do |j|
        (0...SIZE-1).each do |i|
          left = self[i, j]
          right = self[i + 1, j]
          self[i, j] = right
          self[i + 1, j] = Token::NONE
          if groups?
            moves.push({:start => [i, j], :end => [i + 1, j]})
          else
            self[i, j] = Token::NONE
            self[i + 1, j] = left
            if groups?
              moves.push({:start => [i, j], :end => [i + 1, j]})
            end
          end
          self[i, j] = left
          self[i + 1, j] = right
        end
      end

      # Check for vertical moves
      (0...SIZE-1-pisslevel).each do |j|
        (0...SIZE).each do |i|
          top = self[i, j]
          bottom = self[i, j + 1]
          self[i, j] = bottom
          self[i, j + 1] = Token::NONE
          if groups?
            moves.push({:start => [i, j], :end => [i, j + 1]})
          else
            self[i, j] = Token::NONE
            self[i, j + 1] = top
            if groups?
              moves.push({:start => [i, j], :end => [i, j + 1]})
            end
          end
          self[i, j] = top
          self[i, j + 1] = bottom
        end
      end

      moves
    end

    def legal_move?(move)
      # Note: this function could be optimized by returning prematurely in case of success
      moves.each do |legal|
        if move == legal
          return true
        end
      end
      false
    end

    private

    def each_cell_from_bottom
      (SIZE - 1).downto(0) do |j|
        0.upto(SIZE - 1) do |i|
          yield i, j
        end
      end
    end

    def destroy_groups(groups)
      # Warning: this operation is tricky since we have to make sure that super-gems that are also members of a <=4 group stay
      # on board without any influence of the group destroy orders. To this prupose, destroy is implemented as a multiple pass
      # process.
      groups.each do |group|
        group.each_cell do |i, j|
          self[i, j] = Token::NONE
        end
      end
      groups.each do |group|
        if group.length >= 5
          self[group.midx, group.midy] = group.token.upcase
        end
      end
    end

    def compact
      compacted = true
      while compacted
        compacted = false
        each_cell_from_bottom do |i, j|
          if self[i, j] == Token::NONE
            self[i, j] = self[i, j - 1]
            self[i, j - 1] = Token::NONE
            compacted = true
          end
        end
        (0...SIZE).each do |i|
          if self[i, 0] == Token::NONE
            self[i, 0] = generate_cell
          end
        end
      end
    end

    def generate_cell

    end

  end
end
