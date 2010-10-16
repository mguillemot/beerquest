module UserHelper

  def favorite_pages(current_page, max_page)
    result = ""
    if max_page > 1
      result += t('home.score.tabs.pages') + " "
      (1..max_page).each do |page|
        if page == current_page
          result += "<span class=\"page-link current\">#{page}</span> "
        else
          result += link_to(page.to_s, async_favorites_url(page), :remote => true, :class => 'page-link') + " "
        end
      end
      # TODO "..."
    end
    result.html_safe
  end

  def partner_pages(current_page, max_page)
    result = ""
    if max_page > 1
      result += t('home.score.tabs.pages') + " "
      (1..max_page).each do |page|
        if page == current_page
          result += "<span class=\"page-link current\">#{page}</span> "
        else
          result += link_to(page.to_s, async_partners_url(page), :remote => true, :class => 'page-link') + " "
        end
      end
      # TODO "..."
    end
    result.html_safe
  end

  def search_prefixes(current_prefix)
    result = ""
    result += link_to('123', async_search_url('123', 1), :remote => true, :class => 'page-link') + " "
    "A".ord.upto("Z".ord).each do |letter|
      result += "<br/>" if letter == "M".ord
      if letter.chr == current_prefix
        result += "<span class=\"page-link current\">#{letter.chr}</span> "
      else
        result += link_to(letter.chr, async_search_url(letter.chr, 1), :remote => true, :class => 'page-link') + " "
      end
    end
    result.html_safe
  end

  def search_pages(prefix, current_page, max_page)
    result = ""
    if max_page > 1
      result += t('home.score.tabs.pages') + " "
      (1..max_page).each do |page|
        if page == current_page
          result += "<span class=\"page-link current\">#{page}</span> "
        else
          result += link_to(page.to_s, async_search_url(prefix, page), :remote => true, :class => 'page-link') + " "
        end
      end
      # TODO "..."
    end
    result.html_safe
  end

end
