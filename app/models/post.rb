class Post < ActiveRecord::Base
  belongs_to :user
  belongs_to :group
  has_many :comments, dependent: :destroy
  has_many :tags, dependent: :destroy
  validates_presence_of :body
  
  mount_uploader :image, ImageUploader
end
