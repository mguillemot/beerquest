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
    end
    result += "</code>"
    @previous_board = board
    result.html_safe
  end

end
