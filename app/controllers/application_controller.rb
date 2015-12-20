class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  helper_method :anon_token
  
  def anon_token
    if cookies[:token_timestamp].nil? or \
      cookies[:token_timestamp].to_datetime < 1.week.ago
      cookies.permanent[:token] = SecureRandom.urlsafe_base64
      cookies.permanent[:token_timestamp] = DateTime.current
    end
    return cookies[:token].to_s
  end
end
