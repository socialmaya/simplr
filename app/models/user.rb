class User < ActiveRecord::Base
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :notes, dependent: :destroy
  has_many :tags, dependent: :destroy
  has_many :groups
  
  validates_presence_of :name, length: { minimum: 3 }
  validates_presence_of :password, length: { minimum: 4 }
  validates_uniqueness_of :name
  validates_confirmation_of :password
  
  before_create :encrypt_password, :generate_token, :gen_unique_token
  
  mount_uploader :image, ImageUploader
  
  def update_token
    self.generate_token
    self.save
  end
  
  def generate_token
    begin
      self.auth_token = SecureRandom.urlsafe_base64
    end while User.exists? auth_token: self.auth_token
  end
  
  def self.authenticate login, password
    user = self.find_by_name login; user = self.find_by_email login unless user
    if user && user.password == BCrypt::Engine.hash_secret(password, user.password_salt)
      user
    else
      nil
    end
  end
  
  private
  
  def gen_unique_token
    self.unique_token = SecureRandom.urlsafe_base64
  end
  
  def encrypt_password
    if self.password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password = BCrypt::Engine.hash_secret(self.password, self.password_salt)
    end
  end
end
