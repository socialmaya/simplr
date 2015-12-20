module ApplicationHelper
  def rand_string
    SecureRandom.urlsafe_base64.gsub(/[^0-9a-z]/i, '')
  end
end
