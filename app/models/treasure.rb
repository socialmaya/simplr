class Treasure < ActiveRecord::Base
  belongs_to :user
  belongs_to :group
  belongs_to :treasure
  has_many :treasures
  
  before_create :gen_unique_token

  mount_uploader :image, ImageUploader
  
  def self.powers
    { read_others_messages: 'Read other peoples messages',
      invade_groups: 'Invade private groups',
      edit_posts: 'Edit posts',
      edit_profiles: 'Edit user profiles',
      edit_groups: 'Edit group profiles',
      shutdown: 'Shutdown entire website',
      take_over: 'Take control over enitre website' }
  end
  
  private
    def gen_unique_token
      self.unique_token = SecureRandom.urlsafe_base64
    end
end
