class Connection < ActiveRecord::Base
  belongs_to :user
  belongs_to :group
  # as folder for messages
  belongs_to :connection
  has_many :connections, dependent: :destroy
  has_many :messages, dependent: :destroy
  
  before_create :gen_unique_token
  
  scope :invites, -> { where invite: true }
  scope :requests, -> { where request: true }
  scope :folders, -> { where message_folder: true }
  scope :current, -> { where.not(invite: true).where.not request: true }
  scope :forrest_only_invites, -> { where invite: true, forrest_only: true }
  
  # finds message folder with specific list of users
  def self.folder_with users=[]
    for user in users
      # goes through each folder in each users inbox
      for folder in user.message_folders
        # goes through each member in each folder, getting array for comparison
        _users = []; folder.members.each { |member| _users << member.user if member.user }
        # sorts and compares each array of users, returns this folder if arrays match
        if _users.sort.eql? users.sort
          _folder = folder
          break
        end
      end
    end
    return _folder
  end
  
  def unseen_messages user
    if self.message_folder and self.messages.present?
      connection = self.connections.find_by_user_id user.id
      unseen = self.messages.size - connection.total_messages_seen.to_i
    else
      unseen = 0
    end
    return unseen
  end
  
  def members
    if self.message_folder
      return self.connections.where.not user_id: nil
    else
      return []
    end
  end
  
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
      self.unique_token = SecureRandom.urlsafe_base64.split('').sample 5
      self.unique_token << "_" + $name_generator.next_name
    end
end
