class LikesController < ApplicationController
  before_action :set_item
  
  def create
    like = @item.likes.new
    if current_user
      like.user_id = current_user.id
    else
      like.anon_token = anon_token
    end
    if like.save
      @like = like
    end
  end
  
  def destroy
    like = if current_user
      @item.likes.where(user_id: current_user.id).last
    else
      @item.likes.where(anon_token: anon_token).last
    end
    like.destroy
  end
  
  private
    def set_item
      @item = if params[:post_id]
        Post.find_by_id params[:post_id]
      elsif params[:post_id]
        Comment.find_by_id params[:comment_id]
      end
    end
end
