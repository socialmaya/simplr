class ItemLibrary < ApplicationRecord
  has_many :shared_items

  validates_presence_of :name
  validates_presence_of :body

  before_create :gen_unique_token

  mount_uploader :image, ImageUploader

  private

  def gen_unique_token
    begin
      self.unique_token = $name_generator.next_name[0..5].downcase
      self.unique_token << "_" + SecureRandom.urlsafe_base64
    end while Survey.exists? unique_token: self.unique_token
  end
end
