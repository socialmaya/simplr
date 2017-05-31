class ViewsController < ApplicationController
  before_action :dev_only, only: [:index]
  
  def index
    @views = View.all.reverse
  end
  
  private
  
  def dev_only
    dev?
  end
end
