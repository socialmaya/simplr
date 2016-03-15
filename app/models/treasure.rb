class Treasure < ActiveRecord::Base
  belongs_to :user
  belongs_to :group
  belongs_to :treasure
  has_many :treasures
  
  before_create :gen_unique_token, :gen_unique_name, :random_xp, :random_power
  validate :one_discovery, :unique_name, on: :create

  mount_uploader :image, ImageUploader
  
  def looted_by? user
    true if self.name.present? and user.treasures.find_by_name self.name
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
      discover: 'Discover secrets',
      invade_groups: 'Invade private groups',
      make_follower: 'Make someone your follower',
      steal_followers: 'Steal other peoples followers',
      read_others_messages: 'Read other peoples private messages',
      shutdown: 'Shutdown entire website, alter homepage', }
  end
  
  def self.types
    { portal: 'Portal - leads to another treasure',
      maze: 'Maze - choose between two or more',
      prize: 'Prize - rewarded with power or high XP',
      kanye: 'Kanye - nothing but text (dead end)' }
  end
  
  private
    # unique names but doesn't interfere with looting
    def unique_name
      if self.user_id.nil? and self.name.present?
        _treasure = Treasure.find_by_name self.name
        if _treasure
          errors.add :unique_name, "Name must be unique"
        end
      end
    end
    
    # prevents duplicate discover treasures from being created
    def one_discovery
      if self.user_id and self.power.eql? 'discover'
        user = User.find_by_id(self.user_id)
        if user and user.treasures.find_by_power self.power
          errors.add :one_discovery, "Discover only once"
        end
      end
    end
    
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
      if self.treasure_type.eql? 'kanye'
        self.xp = -53
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
