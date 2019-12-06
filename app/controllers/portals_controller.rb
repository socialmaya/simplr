class PortalsController < ApplicationController
  before_action :invite_only, except: [:show, :enter, :to_anrcho]
  before_action :dev_only, only: [:index, :destroy, :destroy_all, :update, :disseminator]
  before_action :set_portal, only: [:copy_link, :edit, :show, :update, :destroy]
  before_action :set_portal_securely, only: [:enter, :to_anrcho]

  # enables secure transition from maya to anrcho
  def to_anrcho
    if @portal and @portal.to_anrcho
      @user = @portal.user; @portal.destroy; cookies.permanent[:auth_token] = @user.auth_token
      redirect_to proposals_path, notice: "Successfully decrypted account from Social Maya..." if current_user
    else
      redirect_to '/404'
    end
  end

  def disseminator
    @portal = Portal.loners.sort_by{|p| p.remaining_uses}.last
  end

  def edit
  end

  def update
    if @portal.update(portal_params)
      notice = "Portal updated successfully..."
    else
      notice = "Portal update failed..."
    end
    redirect_to show_portal_path(@portal.unique_token), notice: notice
  end

  def copy_link
  end

  def cluster_flier
    @cluster_flier_page = true
    @cluster = Portal.find_by_unique_token params[:token]
    @portals = @cluster.portals
  end

  def clusters
    @clusters = Portal.clusters.sort_by {|p| p.created_at }.reverse
    for cluster in @clusters
      if DateTime.current > cluster.expires_at or not cluster.portals.present?
        cluster.destroy
      end
    end
  end

  def index
    @portals_index = true
    @portals = Portal.loners.sort_by {|p| p.created_at }.reverse
    for portal in @portals
      if DateTime.current > portal.expires_at
        portal.destroy
      end
    end
  end

  def show_cluster
    @showing_cluster = true
    @cluster = Portal.find_by_unique_token params[:token]
    @portals = @cluster.portals
  end

  # page that actually shows the portal
  def show
  end

  # A digital portal to a digital dimension
  def enter # enables users to enter site without invite
    # goes back home if users already invited, saving portal space
    if invited?
      redirect_to (raleigh_dsa? ? surveys_path : root_url)
    elsif @portal
      if @portal.remaining_uses > 0 and DateTime.current < @portal.expires_at
        invite = Connection.new invite: true, redeemed: true
        if invite.save
          @portal.update remaining_uses: @portal.remaining_uses - 1
          cookies.permanent[:invite_token] = invite.unique_token
          # sets cookie for admin access if portal was set for admin
          cookies.permanent[:grant_admin_access] = true if @portal.admin
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
    @portal.user_id = current_user.id
    # sets up for regular portal to begin with
    @portal.remaining_uses = params[:remaining_uses]
    if params[:remaining_days].present?
      @portal.expires_at = params[:remaining_days].to_i.days.from_now.to_datetime
    end
    # grants dev access when user signs up from this portal
    @portal.dev = true if params[:grant_dev_access]
    if raleigh_dsa?
      @portal.admin = true if params[:grant_admin_access]
      # sets up as dsa portal if created from raleighdsa.com
      @portal.to_dsa = true
    end
    # creates portal cluster
    if params[:cluster_size] and not params[:cluster_size].to_i.zero? and dev?
      @cluster = Portal.create cluster: true, expires_at: @portal.expires_at
      if @cluster
        params[:cluster_size].to_i.times do
          Portal.create(
            cluster_id: @cluster.id,
            remaining_uses: @portal.remaining_uses,
            expires_at: @portal.expires_at
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
          if raleigh_dsa?
            redirect_to dsa_admin_path(portal_token: @portal.unique_token)
          else
            redirect_to dev_panel_path(portal_token: @portal.unique_token)
          end
        end
      end
    end
  end

  def destroy
    @was_a_cluster = @portal.cluster
    if @portal
      @portal.destroy
    end
    if @was_a_cluster
      redirect_to dev_panel_path
    else
      redirect_to (raleigh_dsa? ? dsa_admin_path : :back)
    end
  end

  def destroy_all
    Portal.loners.send(raleigh_dsa? ? :to_dsa : :all).each do |portal|
      portal.destroy
    end
    redirect_to :back
  end

  private

  # integer id is too easy to guess
  def set_portal_securely
    @portal = Portal.find_by_unique_token(params[:token])
    redirect_to '/404' unless @portal
  end

  def set_portal
    if params[:token]
      @portal = Portal.find_by_unique_token(params[:token])
      @portal ||= Portal.find_by_id(params[:token])
    else
      @portal = Portal.find_by_id(params[:id])
      @portal ||= Portal.find_by_unique_token(params[:id])
    end
    redirect_to '/404' unless @portal
  end

  def dev_or_admin_only
    unless dev? or admin?
      redirect_to '/404'
    end
  end

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

  # Never trust parameters from the scary internet, only allow the white list through.
  def portal_params
    params.require(:portal).permit(:unique_token)
  end
end
