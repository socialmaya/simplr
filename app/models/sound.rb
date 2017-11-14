class Sound < ApplicationRecord
  belongs_to :group
  belongs_to :user
  belongs_to :post
  
  mount_uploader :audio, ImageUploader
end
