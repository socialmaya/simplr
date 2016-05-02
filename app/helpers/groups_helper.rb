module GroupsHelper
  def featured_groups
    featured = []
    Group.where.not(image: nil).each do |group|
      # featured unless logged in and already joined
      featured << group unless my_groups.include? group
    end
    return featured.last(4).reverse
  end
  
  def my_group_options
    options = [["Choose a group", nil]]
    for group in my_groups
      options << [group.name, group.id]
    end
    return options
  end
  
  def my_groups
    _my_groups = []
    if current_user
      current_user.my_groups.each { |group| _my_groups << group }
    elsif anon_token
      Group.where(anon_token: anon_token).each { |group| _my_groups << group }
      Connection.where(anon_token: anon_token).where.not(group_id: nil).each do |connection|
        _my_groups << connection.group if connection.group
      end
    end
    return _my_groups
  end
  
  def group_member_auth group
    if current_user
      if group.members.find_by_user_id current_user.id or current_user.has_power? 'invade_groups'
        true
      end
    end
  end
  
  def group_auth group
    if current_user
      return current_user.id.eql? group.user_id
    else
      return anon_token.eql? group.anon_token
    end
  end
end
