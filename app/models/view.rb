class View < ActiveRecord::Base
  belongs_to :user
  belongs_to :group
  belongs_to :post
  belongs_to :comment
  
  def get_location
    ip = self.ip_address
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
    return locale
  end
end
