class View < ActiveRecord::Base
  belongs_to :user
  belongs_to :group
  belongs_to :post
  belongs_to :message
  belongs_to :comment
  belongs_to :proposal
  
  before_create :set_locale
  
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
  
  private
  
  def set_locale
    if self.ip_address
      self.locale = View.get_locale(self.ip_address)[:address]
    end
  end
end
