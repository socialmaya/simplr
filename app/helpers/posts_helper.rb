module PostsHelper
  def post_goto_link post, url=nil
    goto_link = (url ? url : root_url).gsub("http", "http#{in_dev? ? '' : 's'}"); goto_link.slice!(-1);
    goto_link << "?goto=post_#{post.id}"
    goto_link
  end

  def show_card? post
    #if post.group.nil? or group_auth post.group or group_member_auth post.group or (visible_to_anons? post.group and not post.group.hidden) or own_item? post) and not ((post.hidden or (post.user and post.user.hidden)) and not own_item? post)
    true
  end

  def original_post_pictures post
    if post.original_id
      original = Post.find_by_id post.original_id
      if original
        # ensures photoset order if its been changed by op
        originals = original.pictures.to_a
        originals.sort_by { |i| i.order } if originals.present? and originals.first.ensure_order
        return originals
      end
    else
      # ensures photoset order if its been changed
      pictures = post.pictures.to_a
      pictures.sort_by! { |i| i.order } if pictures.present? and pictures.first.ensure_order
      return pictures
    end
  end

  def original_post_image post
    if post.original_id
      original = Post.find_by_id post.original_id
      if original
        return original.image
      end
    else
      return post.image
    end
  end
end
