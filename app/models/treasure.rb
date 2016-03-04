class Treasure < ActiveRecord::Base
  belongs_to :user
  belongs_to :group
  belongs_to :treasure
  has_many :treasures
  
  before_create :gen_unique_token, :random_xp
  validates_uniqueness_of :name

  mount_uploader :image, ImageUploader
  
  def self.powers
    { read_others_messages: 'Read other peoples messages',
      invade_groups: 'Invade private groups',
      edit_posts: 'Edit posts',
      edit_profiles: 'Edit user profiles',
      edit_groups: 'Edit group profiles',
      shutdown: 'Shutdown entire website',
      take_over: 'Take control over entire website' }
  end
  
  private
    def random_xp
      if self.xp.nil?
        xp_amounts = Fibonacci.seq 5..17
        i=1; for xp in xp_amounts
          if rand(0..i).zero?
            self.xp = xp
            break
          end
          i+=1
        end
        self.xp ||= xp_amounts[0]
      end
    end
    
    def gen_unique_token
      self.unique_token = SecureRandom.urlsafe_base64
    end
end
