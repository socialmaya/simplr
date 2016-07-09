class PortalsController < ApplicationController
  before_action :invite_only, except: [:show, :enter]
  
  def index
    @portals = Portal.all.reverse
  end
  
  # page that actually shows the portal
  def show
    @portal = Portal.find_by_unique_token params[:token]
  end
  
  # A digital portal to a digital dimension
  def enter # enables users to enter site without invite
    @portal = Portal.find_by_unique_token params[:token]
    if @portal
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
  
  private
    def invite_only
      unless invited?
        redirect_to invite_only_path
      end
    end
end
