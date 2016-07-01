class Message < ActiveRecord::Base
  belongs_to :user
  belongs_to :group
  belongs_to :connection
  
  has_many :views
  
  validate :body_or_image
  
  before_create :encrypt_message
  
  mount_uploader :image, ImageUploader
  
  private
    def encrypt_message
      if self.body.present?
        key = self.sender_token
        self.salt = BCrypt::Engine.generate_salt
        key = ActiveSupport::KeyGenerator.new(key).generate_key(self.salt)
        encryptor = ActiveSupport::MessageEncryptor.new(key)
        self.body = encryptor.encrypt_and_sign(self.body)
      end
    end
    
    def body_or_image
      if (self.body.nil? or self.body.empty?) and !self.image.url
        errors.add(:no_content, "Your message was void of content.")
      end
    end
end
