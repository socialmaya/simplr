class User < ActiveRecord::Base
  has_many :connections, dependent: :destroy
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
  
  def following? other_user
    self.connections.where(other_user_id: other_user.id).present?
  end
  
  def follow other_user
    self.connections.create other_user_id: other_user.id
  end
  
  def unfollow other_user
    connection = self.connections.find_by_other_user_id(other_user.id)
    connection.destroy if connection
  end
  
  def following
    _following = []
    self.connections.each do |connection|
      _following << User.find_by_id(connection.other_user_id)
    end
    return _following
  end
  
  def followers
    _followers = []
    Connection.where(other_user_id: self.id).each do |connection|
      _followers << connection.user if connection.user
    end
    return _followers
  end
  
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
