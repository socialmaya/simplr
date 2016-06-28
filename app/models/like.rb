class Like < ActiveRecord::Base
  belongs_to :user
  belongs_to :post
  belongs_to :comment
  
  before_create :gen_unique_token

  private
    def gen_unique_token
      self.unique_token = SecureRandom.urlsafe_base64
    end
end
