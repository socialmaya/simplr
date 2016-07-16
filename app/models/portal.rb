class Portal < ActiveRecord::Base
  EXPIRES_AT = 1.week.from_now.to_datetime
  REMAINING_USES = 5
  
  before_create :gen_unique_token, :initialize_portal
    
  private
    # defaults to 5 uses and expires a week from now
    def initialize_portal
      self.expires_at ||= EXPIRES_AT
      self.remaining_uses ||= REMAINING_USES
    end

    def gen_unique_token
      self.unique_token = SecureRandom.urlsafe_base64
    end
end
