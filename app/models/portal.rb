class Portal < ActiveRecord::Base
  before_create :gen_unique_token, :initialize_portal
    
  private
    # defaults to 5 uses and expires a week from now
    def initialize_portal
      self.expires_at ||= 1.week.from_now.to_datetime
      self.remaining_uses ||= 5
    end

    def gen_unique_token
      self.unique_token = SecureRandom.urlsafe_base64
    end
end
