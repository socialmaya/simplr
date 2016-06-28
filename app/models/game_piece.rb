class GamePiece < ActiveRecord::Base
  belongs_to :game_piece
  belongs_to :treasure
  belongs_to :secret
  belongs_to :user
  
  has_many :game_pieces
  
  before_create :gen_unique_token

  mount_uploader :image, ImageUploader
  
  private
    def gen_unique_token
      self.unique_token = SecureRandom.urlsafe_base64
    end
end
