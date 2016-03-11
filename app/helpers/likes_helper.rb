module LikesHelper
  def already_liked? item
    if current_user
      if item.likes.where(user_id: current_user.id).present?
        return true
      end
    else
      if item.likes.where(anon_token: anon_token).present?
        return true
      end
    end
  end
end
