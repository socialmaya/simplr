class Like < ActiveRecord::Base
  belongs_to :user
  belongs_to :post
  belongs_to :comment
  belongs_to :proposal
  belongs_to :like
  
  has_many :likes, dependent: :destroy
  has_many :comments, dependent: :destroy
  
  before_create :gen_unique_token
  
  scope :loves, -> { where love: true }
  scope :whoas, -> { where whoa: true }
  
  def _likes
    self.likes.where love: nil, whoa: nil
  end

  private
  
  def gen_unique_token
    self.unique_token = SecureRandom.urlsafe_base64
  end
end
