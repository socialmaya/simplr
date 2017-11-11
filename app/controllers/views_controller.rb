class ViewsController < ApplicationController
  before_action :god_only, only: [:user_index]
  before_action :dev_only, only: [:index]
  
  def user_index
    @user = User.find_by_unique_token params[:token]
    @unique_views = [] # unique by locale
    for view in @user.views
      @unique_views << view unless @unique_views.any? { |v| v.locale.eql? view.locale }
    end
  end
  
  def index
    @views = View.all.reverse
  end
  
  private
  
  def god_only
    
  end
  
  def god_only
    redirect_to '/404' unless god?
  end
  
  def dev_only
    redirect_to '/404' unless dev?
  end
end
