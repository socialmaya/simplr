class PagesController < ApplicationController
  before_action :set_human
  
  def resume
  end
  
  def more
    if session[:page].nil? or session[:page] * page_size <= relevant_items.size
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
    if session[:nav_menu_shown].present? and session[:nav_menu_shown_at].to_datetime > 5.second.ago
      @nav_menu_shown = true
      session[:nav_menu_shown] = ''
    else
      @nav_menu_shown = false
      session[:nav_menu_shown] = true
      session[:nav_menu_shown_at] = DateTime.current
    end
  end
  
  private
    def set_human
      cookies.permanent[:probably_human] = true unless current_user
    end
    
    def build_feed_data
      @all_items = relevant_items
      @items = paginate @all_items
      @char_codes = char_codes @items
      @char_bits = char_bits @items
      # records being seen
      @items.each {|item| seent item}
    end
    
    def relevant_items
      if params[:posts]
        @home_shown = true
        if current_user
          return current_user.feed
        else
          return Post.all.reverse
        end
      elsif params[:group_id]
        @group_shown = true
        return Group.find_by_id(params[:group_id]).posts.reverse
      end
    end
end
