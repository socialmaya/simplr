class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :post
  belongs_to :comment
  
  has_many :comments, dependent: :destroy
  has_many :tags, dependent: :destroy
  
  mount_uploader :image, ImageUploader
  
  def replies
    self.comments
  end
end
