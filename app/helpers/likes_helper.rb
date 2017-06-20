module LikesHelper
  def get_like_type_str link=nil
    like_type = if @like.love
      'love'
    elsif @like.whoa
      'whoa'
    elsif @like.zen
      'zen'
    else
      'like'
    end
    if link
      if not like_type.eql? 'like'
        like_type = like_type + '_link'
      else
        like_type = 'link'
      end
    end
    like_type
  end
  
  def get_like_liked_post like
    begin
      like = like.like
    end while like.post.nil?
    return like.post
  end
  
  def get_like_like note
    post = Like.find(note.item_id).post if Like.find_by_id note.item_id
    if current_user
      like = if post
        post.likes.find_by_user_id current_user.id
      else
        Like.find_by_id note.item_id
      end
    else
      post.likes.find_by_anon_token anon_token
    end
    like = if note.sender_id
      like.likes.find_by_user_id note.sender_id
    else
      like.likes.find_by_anon_token note.sender_token
    end
    return like
  end
  
  def already_loved? item
    if current_user
      if item.loves.where(user_id: current_user.id).present?
        return true
      end
    else
      if item.loves.where(anon_token: anon_token).present?
        return true
      end
    end
  end
  
  def already_zend? item
    if current_user
      if item.zens.where(user_id: current_user.id).present?
        return true
      end
    else
      if item.zens.where(anon_token: anon_token).present?
        return true
      end
    end
  end
  
  def already_whoad? item
    if current_user
      if item.whoas.where(user_id: current_user.id).present?
        return true
      end
    else
      if item.whoas.where(anon_token: anon_token).present?
        return true
      end
    end
  end
  
  def already_liked? item
    if current_user
      if item._likes.where(user_id: current_user.id).present?
        return true
      end
    else
      if item._likes.where(anon_token: anon_token).present?
        return true
      end
    end
  end
end
