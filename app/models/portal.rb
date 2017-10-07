class Portal < ActiveRecord::Base
  before_create :gen_unique_token, :initialize_portal
  
  DEFAULT_REMAINING_USES = 5
  
  def self.expiration_date
    1.week.from_now.to_datetime
  end
    
  private
    # defaults to 5 uses and expires a week from now
    def initialize_portal
      self.expires_at ||= Portal.expiration_date
      self.remaining_uses ||= DEFAULT_REMAINING_USES
    end

    def gen_unique_token
      self.unique_token = SecureRandom.urlsafe_base64.split('').sample(5).join
      self.unique_token << "_" + $name_generator.next_name
    end
end
