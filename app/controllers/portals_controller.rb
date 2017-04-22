class PortalsController < ApplicationController
  before_action :invite_only, except: [:show, :enter]
  before_action :dev_only, only: [:index]
  
  def index
    @portals = Portal.all.reverse
    for portal in @portals
      if DateTime.current > portal.expires_at
        portal.destroy
      end
    end
  end
  
  # page that actually shows the portal
  def show
    @portal = Portal.find_by_unique_token params[:token]
  end
  
  # A digital portal to a digital dimension
  def enter # enables users to enter site without invite
    @portal = Portal.find_by_unique_token params[:token]
    # goes back home if users already invited, saving portal space
    if invited?
      redirect_to root_url
    elsif @portal
      if @portal.remaining_uses.to_i > 0 and DateTime.current < @portal.expires_at
        invite = Connection.new invite: true, redeemed: true
        if invite.save
          @portal.update remaining_uses: @portal.remaining_uses - 1
          cookies.permanent[:invite_token] = invite.unique_token
          cookies.permanent[:human] = true
          redirect_to new_user_path
        end
      else
        @portal.destroy
        redirect_to root_url
      end
    else
      redirect_to '/404'
    end
  end
  
  def create
    @portal = Portal.new
    @portal.remaining_uses = params[:remaining_uses]
    if params[:remaining_days].present?
      @portal.expires_at = params[:remaining_days].to_i.days.from_now.to_datetime
    end
    if @portal.save
      if dev?
        redirect_to dev_panel_path(portal_token: @portal.unique_token)
      else
        redirect_to :back
      end
    end
  end
  
  def destroy
    @portal = Portal.find_by_unique_token params[:token]
    if @portal
      @portal.destroy
    end
    redirect_to :back
  end
  
  private
    def dev_only
      unless dev?
        redirect_to '/404'
      end
    end
    
    def invite_only
      unless invited?
        redirect_to invite_only_path
      end
    end
end
