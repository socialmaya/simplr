class Group < ActiveRecord::Base
  belongs_to :user
  has_many :posts, dependent: :destroy
  has_many :connections, dependent: :destroy
  
  mount_uploader :image, ImageUploader
  
  def members
    _members = []
    self.connections.each do |connection|
      _members << connection.user if connection.user
    end
    return _members
  end
end
