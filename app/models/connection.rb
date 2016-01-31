class Connection < ActiveRecord::Base
  belongs_to :user
  belongs_to :group
  
  before_create :gen_unique_token
  
  scope :invites, -> { where invite: true }
  scope :requests, -> { where request: true }
  scope :current, -> { where.not(invite: true).where.not request: true }
  
  def invited_to_site?
    self.invite and self.user_id.nil? and self.group_id.nil?
  end
  
  private
  
  # not currently in use
  def unique_to_user
    connections = User.find_by_id(self.user_id).connections
    if connections.find_by_other_user_id self.other_user_id or connections.find_by_group_id self.group_id
      errors.add(:connection, "already exists.")
    end
  end

  def gen_unique_token
    self.unique_token = SecureRandom.urlsafe_base64
  end
end
