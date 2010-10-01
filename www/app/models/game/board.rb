module Game
  class Board

    SIZE = 8

    attr_accessor :pisslevel

    def initialize(seed = nil, group_collection_handler = nil)
      @cells = Token::NONE * (SIZE * SIZE)
      @pisslevel = 0
      @rand = DeadBeefRandom.new(seed || rand())
      @group_collection_handler = group_collection_handler
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

    def generate_random_keeping_some_vomit
      vomits = cells_of_type(Token::VOMIT)
      unless vomits.empty?
        vomits = vomits.randomize(@rand)
        to_remove = (vomits.length * 0.25).floor
        vomits[to_remove, -1] = nil
      end
      begin
        generate_full_random
        normalize
        vomits.each do |v|
          self[v[0], v[1]] = Token::VOMIT
        end
      end while moves.empty?
    end

    def normalize
      collected_groups = []
      while groups?
        gs = groups
        destroy_groups(gs)
        collected_groups += gs
        compact
      end
      if @group_collection_handler
        collected_groups.each { |g| @group_collection_handler.call(g) }
      end
      collected_groups
    end

    def swap_cells(source, destination)
      self[source[0], source[1]], self[destination[0], destination[1]] = self[destination[0], destination[1]], self[source[0], source[1]]
      normalize
    end

    def create_vomit(count)
      cells = []
      count.times do
        cell = get_random_non_vomit_non_super_cell
        if cell
          cells.push(cell)
        end
      end
      transform_cells(cells, Token::VOMIT, true) # impossible to create new groups, so no collection should take place here
      cells
    end

    def transform_cells(cells, target, reset_super)
      cells.each do |cell|
        token = (!reset_super && self[cell[0], cell[1].super?]) ? target.upcase : target
        self[cell[0], cell[1]] = token
      end
      normalize
    end

    def transform_tokens_of_type(source, target)
      cells = []
      each_cell_from_top do |i, j|
        cells.push [i, j] if self[i, j].downcase == source
      end
      transform_cells(cells, target, false)
      cells
    end

    def destroy_tokens_of_type(target)
      count = supers = 0
      each_cell_from_top do |i, j|
        if self[i, j].downcase == target
          count += 1
          supers += 1 if self[i, j].super?
          self[i, j] = Token::NONE
        end
      end
      compact
      normalize
      supers * Constants::SUPER_TOKEN_VALUE + count
    end

    private

    def get_random_non_vomit_non_super_cell
      count = 0
      each_cell_from_top do |i, j|
        count += 1 if self[i, j] == Token::VOMIT || self[i, j].super?
      end
      return nil if count == SIZE * SIZE
      while true
        x = @rand.next_int(0, SIZE - 1)
        y = @rand.next_int(0, SIZE - 1)
        return [x, y] if self[x, y] != Token::VOMIT && !self[x, y].super?
      end
    end

    def each_cell_from_top
      0.upto(SIZE - 1) do |j|
        0.upto(SIZE - 1) do |i|
          yield i, j
        end
      end
    end

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
      r = @rand.next_int(1, 17)
      if r <= 3
        Token::BLOND_BEER
      elsif r <= 6
        Token::BROWN_BEER
      elsif r <= 9
        Token::AMBER_BEER
      elsif r <= 11
        Token::FOOD
      elsif r <= 13
        Token::WATER
      elsif r <= 15
        Token::LIQUOR
      else
        Token::TOMATO_JUICE
      end
    end

    def clear_supers
      @cells.downcase!
    end

    def generate_full_random
      each_cell_from_top do |i, j|
        self[i, j] = generate_cell
      end
    end

    def generate_random_without_groups
      begin
        generate_full_random
        normalize
      end while moves.empty?
      clear_supers
    end

    def cells_of_type(token)
      token = token.downcase
      result = []
      each_cell_from_top do |i, j|
        if self[i, j].downcase == token
          result.push [i, j]
        end
      end
      result
    end

  end
end

class Array
  def randomize(rand)
    clone = dup
    result = []
    while !clone.empty?
      i = rand.next_int(0, clone.length - 1)
      result.push(clone[i])
      clone[i] = nil
    end
    result
  end
end
