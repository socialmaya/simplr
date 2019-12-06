class View < ActiveRecord::Base
  belongs_to :user
  belongs_to :group
  belongs_to :post
  belongs_to :message
  belongs_to :comment
  belongs_to :proposal
  belongs_to :vote

  before_create :set_locale

  validate :unique_to_item?, on: :create

  scope :by_user, -> { where.not user_id: nil }
  scope :anon, -> { where(user_id: nil).where.not(anon_token: nil) }
  scope :with_locale, -> { where.not(locale: nil).where.not locale: "" }
  scope :item_views, -> { where.not click: true }
  scope :clicks, -> { where click: true }
  scope :with_size, -> { where.not screen_height: nil }

  def self.screen_size_proportions
    widths = screen_sizes.map { |s| s[0] }
    heights = screen_sizes.map { |s| s[1] }


  end

  # get different screen_sizes used by users
  def self.screen_sizes
    sizes = []
    clicks.with_size.each do |c|
      sizes << [c.screen_width, c.screen_height]
    end
    # removes duplicates and sorts by width
    sizes.uniq.sort_by { |s| s[0] }
  end

  def self.unique_views
    _unique_views = []
    for view in self.by_user.with_locale.reverse
      _unique_views << view unless _unique_views.any? { |v| v.locale.eql? view.locale }
    end
    return _unique_views
  end

  def self.get_locale ip=nil
    ip = if ip then ip else self.ip_address end
    address = nil; locale = nil
    geoip = GeoIP.new('GeoLiteCity.dat').city(ip)
    if defined? geoip and geoip
      if geoip.latitude and geoip.longitude
        geocoder = Geocoder.search("#{geoip.latitude}, #{geoip.longitude}").first
        if geocoder and geocoder.formatted_address
          address = geocoder.formatted_address
        end
      end
    end
    locale = if address.present?
      { address: address, lat: geoip.latitude, lon: geoip.longitude }
    else
      {}
    end
    locale
  end

  def user_locale
    if self.user_id and User.find_by_id(self.user_id) and User.find_by_id(self.user_id).location.present?
      return User.find_by_id(self.user_id).location
    end
    nil
  end

  private

  def unique_to_item?
    unless self.click
      if self.post_id
        if self.user_id
          if Post.find(self.post_id).views.where(user_id: self.user_id).present?
            errors.add :view, "Not unique view by user"
          end
        elsif self.anon_token
          if Post.find(self.post_id).views.where(anon_token: self.anon_token).present?
            errors.add :view, "Not unique view by anon"
          end
        end
      elsif self.proposal_id
        if self.user_id
          if Proposal.find(self.proposal_id).views.where(user_id: self.user_id).present?
            errors.add :view, "Not unique view of motion by user"
          end
        elsif self.anon_token
          if Proposal.find(self.proposal_id).views.where(anon_token: self.anon_token).present?
            errors.add :view, "Not unique view of motion by anon"
          end
        end
      end
    end
  end

  def set_locale
    self.locale = if self.user_locale
      self.user_locale
    elsif self.ip_address
      View.get_locale(self.ip_address)[:address]
    end
  end
end
