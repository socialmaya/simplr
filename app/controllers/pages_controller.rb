class PagesController < ApplicationController
  def more
    if session[:page].nil? or session[:page] * page_size <= Post.all.size
      if session[:page]
        session[:page] += 1
      else
        session[:page] = 1
      end
    end
    build_feed_data
  end

  def scroll_to_top
  end
  
  def toggle_menu
    # if nav menu is already open and was opened in the last 10 seconds
    if session[:nav_menu_shown].present? and session[:nav_menu_shown_at].to_datetime > 10.second.ago
      @nav_menu_shown = true
      session[:nav_menu_shown] = ''
    else
      @nav_menu_shown = false
      session[:nav_menu_shown] = true
      session[:nav_menu_shown_at] = DateTime.current
    end
  end
  
  private
  
  def build_feed_data
    @all_items = Post.all.reverse
    @items = paginate @all_items
    @char_codes = char_codes @items
  end
end
