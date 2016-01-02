class Connection < ActiveRecord::Base
  belongs_to :user
  belongs_to :group
  
  validate :unique_to_user, on: :create
  
  private
    
  def unique_to_user
    connections = User.find_by_id(self.user_id).connections
    if connections.find_by_other_user_id self.other_user_id or connections.find_by_group_id self.group_id
      errors.add(:connection, "already exists.")
    end
  end
end
