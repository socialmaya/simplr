class TemplateItem < ApplicationRecord
  validates_presence_of :body
  validates_presence_of :tag

  before_create :gen_unique_token

  mount_uploader :image, ImageUploader

  private

  def gen_unique_token
    begin
      self.unique_token = $name_generator.next_name[0..5].downcase
      self.unique_token << "_" + SecureRandom.urlsafe_base64.split('').sample(2).join.downcase.gsub("_", "").gsub("-", "")
    end while TemplateItem.exists? unique_token: self.unique_token
  end
end
