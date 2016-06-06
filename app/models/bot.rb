class Bot < ActiveRecord::Base
  has_many :bot_tasks, dependent: :destroy
  
  before_create :generate_token, :gen_unique_token, :gen_unique_bot_name

  mount_uploader :image, ImageUploader
  
  private  
    def gen_unique_token
      self.unique_token = SecureRandom.urlsafe_base64
    end
    
    # sets a generic bot name for bot unless named by user
    def gen_unique_bot_name
      if self.bot and not self.name.present?
        self.name = "bot_#{SecureRandom.urlsafe_base64}"
      end
    end
end
