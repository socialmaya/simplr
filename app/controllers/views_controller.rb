class ViewsController < ApplicationController
  before_action :god_only, only: [:user_index, :index]
  
  def user_index
    @user = User.find_by_unique_token params[:token]
    @unique_views = [] # unique by locale
    for view in @user.views
      @unique_views << view unless @unique_views.any? { |v| v.locale.eql? view.locale }
    end
  end
  
  def index
    @views = View.all.unique_views.sort_by { |v| v.created_at }.reverse
  end
  
  private
  
  def god_only
    redirect_to '/404' unless god?
  end
end
