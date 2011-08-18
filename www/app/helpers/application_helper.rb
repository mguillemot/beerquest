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
    result          += "</code>"
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

  def admin?
    @admin
  end

  def required_version
    return Game::Constants::DEBUG_VERSION if @admin
    Game::Constants::RELEASE_VERSION
  end

  def client_swf
    file = Game::Constants::RELEASE_VERSION
    file = "#{Game::Constants::DEBUG_VERSION}-debug" if @admin
    static_asset_url("BeerQuest-#{file}.swf", 'swf')
  end

  def static_asset_url(asset, type = 'images')
    "https://npng.org/#{type}/#{asset}"
  end

  def blog_url
    "http://blog.bq-4.com/?lang=#{I18n.locale}"
  end

  def help_url
    case I18n.locale.to_s
      when 'fr'
        "http://blog.bq-4.com/spip.php?article2&lang=fr"
      else
        "http://blog.bq-4.com/spip.php?article4&lang=en"
    end
  end

  def support_us_blog_url
    case I18n.locale.to_s
      when 'fr'
        "http://blog.bq-4.com/spip.php?article19&lang=fr"
      else
        "http://blog.bq-4.com/spip.php?article20&lang=en"
    end
  end

  def bartners_program_url
    case I18n.locale.to_s
      when 'fr'
        "http://blog.bq-4.com/spip.php?article13&lang=fr"
      else
        "http://blog.bq-4.com/spip.php?article14&lang=en"
    end
  end

  def tos_url
    "http://blog.bq-4.com/spip.php?article8&lang=en"
  end

  def privacy_url
    "http://blog.bq-4.com/spip.php?article7&lang=en"
  end

  def portable_brewery_url
    blog_url # TODO à faire
  end

  def world_score_url
    "http://blog.bq-4.com/spip.php?rubrique5&lang=#{I18n.locale}"
  end

  def capacity_tutorial_url
    case I18n.locale.to_s
      when 'fr'
        "http://blog.bq-4.com/?Capacite-speciales&lang=fr"
      else
        "http://blog.bq-4.com/?Special-Ability?lang=en"
    end
  end

end
