class Treasure < ActiveRecord::Base
  belongs_to :user
  belongs_to :group
  belongs_to :treasure
  has_many :treasures
  
  before_create :gen_unique_token, :gen_unique_name, :random_xp, :random_power

  mount_uploader :image, ImageUploader
  
  def looted_by? user
    if self.name.present? and user.treasures.find_by_name self.name
      true; else; false; end
  end
  
  def self.random
    _treasure = nil
    treasures = self.where(treasure_id: nil)
    if treasures.present?
      rand_num = rand 0..treasures.size-1
      i=0; for treasure in treasures
        if i.eql? rand_num
          _treasure = treasure
          break
        end
        i+=1
      end
    else
      _treasure = self.create
    end
    return _treasure
  end
  
  def self.powers
    { # Discovers hidden treasure system, gets access to xp leveling from treasure or general
      discover: 'Discovers secrets',
      edit_posts: 'Edit posts',
      edit_profiles: 'Edit user profiles',
      edit_groups: 'Edit group profiles',
      invade_groups: 'Invade private groups',
      shutdown: 'Shutdown entire website',
      take_over: 'Take control over entire website',
      read_others_messages: 'Read other peoples private messages' }
  end
  
  def self.types
    { portal: 'Portal - leads to another treasure',
      maze: 'Maze - choose between two or more',
      prize: 'Prize - rewarded with power or high XP' }
  end
  
  private
    def random_power
      unless self.power.present?
        powers = Treasure.powers.keys
        i=1; for power in powers
          if rand(0..i).zero?
            self.power = power.to_s
            break
          end
          i+=1
        end
        self.power ||= powers[0].to_s
      end
    end
    
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
    
    # sets a generic placeholder name unless named by user
    def gen_unique_name
      unless self.name.present?
        self.name = "generic_#{SecureRandom.urlsafe_base64}"
      end
    end
    
    def gen_unique_token
      self.unique_token = SecureRandom.urlsafe_base64
    end
end
