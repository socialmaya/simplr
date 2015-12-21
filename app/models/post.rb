class Post < ActiveRecord::Base
  belongs_to :user
  belongs_to :group
  has_many :comments, dependent: :destroy
  has_many :tags, dependent: :destroy
  
  validate :text_or_image?, on: :create
  
  mount_uploader :image, ImageUploader
  
  private
  
  def text_or_image?
    if (self.body.nil? or self.body.empty?) and !self.image.url
      errors.add(:post, "cannot be empty.")
    end
  end
end
