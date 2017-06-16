class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  helper_method :anon_token, :current_user, :current_identity, :mobile?, :browser, :get_location,
    :page_size, :paginate, :reset_page, :char_codes, :char_bits, :settings, :dev?, :anrcho?, :invited?,
    :seen?, :seent, :get_site_title, :record_last_visit, :probably_human, :god?
  
  include SimpleCaptcha::ControllerHelpers
  
  # redirects to resume for I, Forrest Wilkins, the creator of this website
  before_action :forrest_to_resume, except: [:resume]
  
  # redirects to proposals index for anrcho.com
  before_action :anrcho_to_proposals, except: [:index]
  
  # bots go to 404 for all pages
  before_action :bots_to_404
  
  def build_proposal_feed section, group=nil
    reset_page; session[:current_proposal_section] = section.to_s
    proposals = if group then group.proposals else Proposal.globals end
    @all_items = proposals.send(section.to_sym) + (group ? group.posts : [])
    @all_items.sort_by! { |item| item.created_at }
    @char_codes = char_codes @all_items
    @char_bits = char_bits @all_items
    @items = paginate @all_items
    for item in @items
      seent item
    end
  end
  
  def record_last_visit
    if current_user and (cookies[:last_active_at].nil? or cookies[:last_active_at].to_datetime < 1.hour.ago)
      current_user.update last_active_at: DateTime.current
      cookies[:last_active_at] = DateTime.current
    end
  end
  
  def get_site_title
    if anrcho?
      'Anrcho'
    else
      case request.host
      when 'forrestwilkins.com'
        'Forrest Wilkins'
      else
        'Social Maya'
      end
    end
  end
    
  def seent item
    # initial update for group activity
    if item.is_a? Group and current_user
      if item.user_id.eql? current_user.id
        item.update total_items_seen: item.items_total
      else
        member = item.members.find_by_user_id current_user.id
        member.update total_items_seen: item.items_total
      end
    end
    # continues to normal seent
    views = if item.is_a? User
      View.where profile_id: item.id
    else
      item.views
    end
    unless seen? item
      if current_user
        # unless item is the current user or item is not a user at all and belongs to user
        unless current_user.eql? item or (!item.is_a? User and current_user.eql? item.user)
          views.create user_id: current_user.id, ip_address: request.remote_ip
        end
      else
        # unless the non-user, non-group item was posted by current anon
        unless !item.is_a? User and !item.is_a? Group and anon_token.eql? item.anon_token
          views.create anon_token: anon_token, ip_address: request.remote_ip if probably_human or invited?
        end
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
  
  def char_bits items
    bits = [];
    for item in items
      item_string = get_correct_char_str item
      for char in item_string.split("")
        for bit in ("%04b" % char.codepoints.first).split("")
          bits << bit.to_i
        end
      end
    end
    return bits
  end
  
  def char_codes items
    codes = [];
    for item in items
      item_string = get_correct_char_str item
      for char in item_string.split("")
        codes << char.codepoints.first * 0.01
      end
    end
    return codes
  end
  
  # returns anon_token or current_user
  def current_identity
    if current_user
      return current_user
    else
      return anon_token
    end
  end
  
  def anon_token
    unless current_user # signed up and and logged in
      if cookies[:token_timestamp].nil? or \
        cookies[:token_timestamp].to_datetime < 1.week.ago
        cookies.permanent[:token] = $name_generator.next_name + "_" + SecureRandom.urlsafe_base64
        cookies.permanent[:token_timestamp] = DateTime.current
        cookies.permanent[:simple_captcha_validated] = ""
      end
      token = cookies[:token].to_s
    else
      token = nil
    end
    return token
  end
  
  # ensures only humans are counted for views
  # mainly used for the first proposals in main feed
  def probably_human
    # set by 'pages/more' since only humans 'want more'
    # a way to see if the user is probably a human
    cookies[:human]
  end
  
  def anrcho?
    request.host.eql? "anrcho.com" or cookies[:at_anrcho].present?
  end
  
  def invited?
    (cookies[:invite_token].present? and Connection.find_by_unique_token(cookies[:invite_token])) \
      or current_user or User.all.size.zero? or cookies[:zen].present?
  end
  
  def dev?
    current_user and current_user.dev
  end
  
  def god?
    current_user and current_user.god
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
    def get_correct_char_str item
      # gets correct string to push to glimmer
      item_string = "just in case of error" # incase there's no match for some reason idk yet
      item_string = if item.body.present?
        item.body
      # for motions only
      elsif item.image.url
        item.image.url
      # for posts only
      elsif item.pictures.present?
        item.pictures.first.image.url
      end
      return item_string
    end
    
    def anrcho_to_proposals
      if request.host.eql? 'anrcho.com' and not cookies[:at_anrcho].present?
        cookies.permanent[:at_anrcho] = true.to_s
        redirect_to proposals_path
      end
    end
    
    def forrest_to_resume
      if request.host.eql? 'forrestwilkins.com'
        redirect_to resume_path
      end
    end
    
    def bots_to_404
      redirect_to '/404' if request.bot?
    end
end
