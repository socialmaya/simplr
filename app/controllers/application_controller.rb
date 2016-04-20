class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  helper_method :anon_token, :current_user, :mobile?, :browser, :get_location,
    :page_size, :paginate, :reset_page, :char_codes, :settings, :dev?,
    :invited?, :seen?, :seent, :get_site_title, :record_last_visit
  
  # redirects to resume for I, Forrest Wilkins, the creator of this website
  before_action :forrest_to_resume, except: [:resume]
  
  def record_last_visit
    if current_user and cookies[:last_active_at].nil? or cookies[:last_active_at].to_datetime < 1.hour.ago
      current_user.update last_active_at: DateTime.current
      cookies[:last_active_at] = DateTime.current
    end
  end
  
  def get_site_title
    case request.host
    when 'forrestwilkins.com'
      'Forrest Wilkins'
    else
      'Social Maya'
    end
  end
    
  def seent item
    views = if item.is_a? User
      View.where profile_id: item.id
    else
      item.views
    end
    unless seen? item
      if current_user
        views.create user_id: current_user.id
      else
        views.create anon_token: anon_token
      end
    end
  end
  
  def seen? item
    # accounts for profile views
    views = if item.is_a? User
      View.where profile_id: item.id
    else
      item.views
    end
    if current_user
      true if views.where(user_id: current_user.id).present?
    else
      true if views.where(anon_token: anon_token).present?
    end
  end
    
  def settings user=current_user
    if user
      setting = lambda { |name| user.settings.find_by_name name }
      settings = {}; Setting.names.each do |category, names|
        for name in names
          settings[name.to_sym] = setting.call(name).send(category)
        end
      end
      return settings
    else
      return {}
    end
  end
  
  def get_location
    address = nil; locale = nil
    ip = request.remote_ip
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
  
  def paginate items, _page_size=page_size
    return items.
      # drops first several posts if :feed_page
      drop((session[:page] ? session[:page] : 0) * _page_size).
      # only shows first several posts of resulting array
      first(_page_size)
  end

  def page_size
    @page_size = 5
  end
  
  def reset_page
    # resets back to top
    unless session[:more]
      session[:page] = nil
    end
  end
  
  def char_codes items
    codes = []; for item in items
      for char in (item.body.present? ? item.body : item.image.to_s).split("")
        codes << char.codepoints.first * 0.01
      end
    end
    return codes
  end
  
  def anon_token
    unless current_user # signed up and and logged in
      if cookies[:token_timestamp].nil? or \
        cookies[:token_timestamp].to_datetime < 1.week.ago
        cookies.permanent[:token] = SecureRandom.urlsafe_base64
        cookies.permanent[:token_timestamp] = DateTime.current
      end
      token = cookies[:token].to_s
    else
      token = nil
    end
    return token
  end
  
  def invited?
    cookies[:invite_token].present? and Connection.find_by_unique_token(cookies[:invite_token]) or current_user
  end
  
  def dev?
    current_user and current_user.dev
  end

  def current_user
    @current_user ||= User.find_by_auth_token(cookies[:auth_token]) if cookies[:auth_token]
  end
  
  def mobile?
    browser.mobile? or browser.tablet?
  end
  
  def browser
    Browser.new(:ua => request.env['HTTP_USER_AGENT'].to_s, :accept_language => "en-us")
  end
  
  private
  
  def forrest_to_resume
    if request.host.eql? 'forrestwilkins.com'
      redirect_to resume_path
    end
  end
end
