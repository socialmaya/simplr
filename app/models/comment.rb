class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :bot
  belongs_to :post
  belongs_to :comment
  
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :tags, dependent: :destroy
  
  validate :text_or_image?, on: :create
  
  mount_uploader :image, ImageUploader
  
  def replies
    self.comments
  end
  
  private
  
  def text_or_image?
    if (self.body.nil? or self.body.empty?) and !self.image.url
      errors.add(:comment, "cannot be empty.")
    end
  end
end
