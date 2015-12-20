class Group < ActiveRecord::Base
  belongs_to :user
  has_many :posts, dependent: :destroy
  
  mount_uploader :image, ImageUploader
end
