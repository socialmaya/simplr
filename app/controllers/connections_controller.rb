class ConnectionsController < ApplicationController
  before_action :set_item, only: [:new, :create, :update, :destroy,
    :members, :invites, :requests, :following, :followers]
  before_action :invite_only, except: [:invite_only_message, :redeem_invite]
  
  def copy_invite_link
  end
  
  def invite_only_message
  end
  
  def redeem_invite
    @invite = Connection.find_by_unique_token params[:token]
    if @invite and @invite.invited_to_site? and not @invite.redeemed
      @invite.update redeemed: true
      if @invite.redeemed
        cookies.permanent[:invite_token] = @invite.unique_token
        cookies[:grant_dev_access] = @invite.grant_dev_access
      end
      redirect_to new_user_path
    else
      redirect_to '/404'
    end
  end
    
  def generate_invite
    @invite = Connection.new invite: true, grant_dev_access: params[:grant_dev_access]
    if @invite.save
      redirect_to dev_panel_path(invite_token: @invite.unique_token)
    else
      redirect_to :back
    end
  end

  def new
    @connection = Connection.new
  end

  def create
    if @group and @user
      invite = @group.invite_to_join @user
      Note.notify(:group_invite, nil, @user, current_user) if invite
    elsif @group
      request = current_user.request_to_join @group
      if request
        # boolean for ajax
        @requested = true
        # notifies the group creator of a users request to join the group
        Note.notify(:group_request, @group, @group.creator, current_user)
        # notifies all made members of the request to join
        for member in @group.members
          Note.notify(:group_request, @group, member.user, current_user)
        end
      end
    elsif @user
      # follows and sets boolean for ajax script
      connection = current_user.follow @user; @followed = true
      Note.notify(:user_follow, nil, @user, current_user) if connection
    end
    redirect_to :back unless @followed or @requested
  end
  
  # when group invite or request is accepted
  def update
    if @connection
      request = @connection.request
      @connection.update invite: false, request: false
      if @connection.group
        if request
          Note.notify :group_request_accepted, @connection.group, @connection.user, current_user
        end
      end
    end
    redirect_to :back
  end

  def destroy
    if @group and @user
      @group.remove @user
    elsif @group
      # removes user from group and sets boolean for ajax
      @group.remove current_user; @left_group = true
    elsif @user
      current_user.unfollow @user
      @unfollowed = true
    elsif @connection
      @connection.destroy
    end
    redirect_to :back unless @unfollowed or @left_group
  end

  def members
    @members = @group.members
  end

  def invites
    @invites = @user.invites
  end

  def requests
    @requests = @group.requests
  end

  def following
    @following = @user.following
  end

  def followers
    @followers = @user.followers.last(10).reverse
  end

  private
    def invite_only
      unless invited?
        redirect_to invite_only_path
      end
    end
    
    def set_item
      @user = User.find_by_id params[:user_id]
      @group = Group.find_by_id params[:group_id]
      @connection = Connection.find_by_id params[:id] unless @user or @group
    end
end
