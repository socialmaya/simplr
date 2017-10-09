class PortalsController < ApplicationController
  before_action :invite_only, except: [:show, :enter]
  before_action :dev_only, only: [:index]
  
  def clusters
    @clusters = Portal.clusters.reverse
    for cluster in @clusters
      if DateTime.current > cluster.expires_at
        cluster.destroy
      end
    end
  end
  
  def index
    @portals_index = true
    @portals = Portal.loners.reverse
    for portal in @portals
      if DateTime.current > portal.expires_at
        portal.destroy
      end
    end
  end
  
  def show_cluster
    @cluster = Portal.find_by_unique_token params[:token]
    @portals = @cluster.portals
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
    # sets up for regular portal to begin with
    @portal.remaining_uses = params[:remaining_uses]
    if params[:remaining_days].present?
      @portal.expires_at = params[:remaining_days].to_i.days.from_now.to_datetime
    end
    # creates portal cluster
    if params[:cluster_size] and not params[:cluster_size].to_i.zero?
      @cluster = Portal.create cluster: true
      if @cluster
        params[:cluster_size].to_i.times do
          Portal.create(
            cluster_id: @cluster.id,
            remaining_uses: @portal.remaining_uses,
            remaining_days: @portal.remaining_days
          )
        end
      end
      if @cluster and @cluster.portals.present?
        redirect_to show_cluster_path(@cluster.unique_token)
      else
        redirect_to :back
      end
    else
      # saves as regular portal, loner portal
      if @portal.save
        if not dev? or params[:from_portal_index]
          redirect_to :back
        else
          # goes back to dev page for portal link to be copied
          redirect_to dev_panel_path(portal_token: @portal.unique_token)
        end
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
