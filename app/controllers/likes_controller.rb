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
      if (current_user and not @item.user.eql? current_user) or (anon_token and not @item.anon_token.eql? anon_token)
        Note.notify "#{@item.class.to_s.downcase}_like".to_sym, @item, (@item.user ? @item.user : @item.anon_token),
          (current_user ? current_user : anon_token)
      end
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
      elsif params[:comment_id]
        Comment.find_by_id params[:comment_id]
      end
    end
end
