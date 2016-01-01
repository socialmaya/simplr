class ConnectionsController < ApplicationController
  def create
  end
  
  def destroy
  end
  
  def members
    @group = Group.find_by_id params[:group_id]
    @members = @group.members
  end
  
  def following
    @user = User.find_by_id params[:user_id]
    @following = @user.following
  end
  
  def followers
    @user = User.find_by_id params[:user_id]
    @followers = @user.followers
  end
end
