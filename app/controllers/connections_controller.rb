class ConnectionsController < ApplicationController
  before_action :set_item, only: [:create, :destroy, :following, :followers]
  
  def create
    if @user
      current_user.follow @user
    elsif @group
      current_user.connections.create group_id: @user.id
    end
    redirect_to :back
  end
  
  def destroy
    if @user
      current_user.unfollow @user
    elsif @group
      connection = current_user.connections.find_by_group_id(@group.id)
      connection.destroy if connection
    end
    redirect_to :back
  end
  
  def members
    @members = @group.members
  end
  
  def following
    @following = @user.following
  end
  
  def followers
    @followers = @user.followers
  end

  private
  
  def set_item
    @user = User.find_by_id params[:user_id]
    @group = Group.find_by_id params[:group_id]
  end
end
