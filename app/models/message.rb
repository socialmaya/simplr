class Message < ActiveRecord::Base
  belongs_to :user
  belongs_to :group
  
  validate :body_or_image
  
  mount_uploader :image, ImageUploader
  
  private
  
  def body_or_image
    if (self.body.nil? or self.body.empty?) and !self.image.url
      errors.add(:no_content, "Your message was void of content.")
    end
  end
end
