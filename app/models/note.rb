class Note < ActiveRecord::Base
  belongs_to :user
  before_create :write_message
  
  scope :unseen, -> { where seen: [nil, false] }
  
  def self.notify action, item=nil, receiver=nil, sender=nil
    self.create(
      action: action,
      item_id: (item.nil? ? nil : item.id),
      
      # if one of the users is signed up / registered
      user_id: (receiver.is_a?(String) ? nil : (receiver.nil? ? nil : receiver.id)),
      sender_id: (sender.is_a?(String) ? nil : (sender.nil? ? nil : sender.id)),
      
      # if one of the users is anonymous / not signed up
      anon_token: (receiver.is_a?(String) ? receiver : ((item and item.anon_token.present?) ? item.anon_token : nil)),
      sender_token: (sender.is_a?(String) ? sender : nil)
    )
  end
  
  def action_text action
    _actions = { post_comment: "Someone commented on your post.",
      comment_reply: "Someone replied to your comment.",
      group_invite: "You've been invited to a group.",
      group_request: "Someone requested to join #{Group.find(self.item_id).name}." }
    return _actions[action.to_sym]
  end
  
  private
  
  def write_message
    self.message = self.action_text self.action
  end
end
