module GroupsHelper
  def group_member_auth group
    return group.members.find_by_user_id current_user.id
  end
  
  def group_auth group
    if current_user
      return current_user.id.eql? group.user_id
    else
      return anon_token.eql? group.anon_token
    end
  end
end
