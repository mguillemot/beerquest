module ApplicationHelper

  @previous_board = nil

  def board(board)
    result = "<code>"
    (0...Game::Board::SIZE).each do |j|
      (0...Game::Board::SIZE).each do |i|
        if @previous_board && board[i, j] != @previous_board[i, j]
          result += '<span style="background:yellow;">' + board[i, j] + '</span>'
        else
          result += board[i, j]
        end
      end
      result += "<br/>"
      if board.pisslevel > 0 && j == Game::Board::SIZE - 1 - board.pisslevel
        result += "~~~~~~~~<br/>"
      end
    end
    result += "</code>"
    @previous_board = board
    result.html_safe
  end

  def game(game)
    result = "<span class=\"score\">Score = #{game.score}</span> "
    result += "<span class=\"piss-vomit\">Vomit = #{game.vomit} Piss = #{game.piss}</span> "
    result += "<span class=\"turns\">Remaining turns = #{game.remaining_turns}</span> "
    result += "<span class=\"score\">Token collection = #{game.collection.inspect}</span> "
    result += "<span class=\"score\">Capacities = #{game.capacities.inspect}</span> "
    result += "<div class=\"board\">#{board(game.board)}</div>"
    result.html_safe
  end

  def admin
    @me && (@me.id == 1 || @me.id == 2)
  end

end
