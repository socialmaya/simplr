class ViewsController < ApplicationController
  before_action :god_only, only: [:user_index, :index, :show]
  
  def show
    @view = View.find_by_id params[:id]
  end
  
  def user_index
    @user = User.find_by_unique_token params[:token]
    @unique_views = [] # unique by locale
    for view in @user.views
      @unique_views << view unless @unique_views.any? { |v| v.locale.eql? view.locale }
    end
    @views = @unique_views.sort_by { |v| v.created_at }.reverse
    get_most_viewed_locale
    
  end
  
  def index
    @views = View.all.unique_views.sort_by { |v| v.created_at }.reverse
  end
  
  private
  
  def get_most_viewed_locale
    # this first should be last view created
    @most_viewed = @views.first
    a = @user.views.count { |i| i.locale.eql? @most_viewed.locale }
    # loops through all views by user until most viewed from locale is found
    for v in @views.reverse # reverse to lead to first/last created
      b = @user.views.count { |i| i.locale.eql? v.locale }
      if a < b
        @most_viewed = v
        a = b
      end
    end
  end
  
  def god_only
    redirect_to '/404' unless god?
  end
end
