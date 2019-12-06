module ApplicationHelper
  def get_card_type
    if raleigh_dsa?
      'surveys_card'
    elsif social_maya?
      'dark_card'
    else
      'card'
    end
  end

  def middle_dot
    "·"
  end

  def is_a_link? word
    word =~ /\A#{URI::regexp}\z/ or word.include? "http://" or word.include? ".se" \
      and word != "in:" and not (["::", ":)", ":]", "c:"].any? { |i| word.include? i } or word =~ /\w+:/)
  end

  def is_a_yt_link? word
    word =~ /\A#{URI::regexp}\z/ and word.include? "youtu" and !word.include? "user" and !word.include? "channel"
  end

  def standard_dark_card id='', alignment='center', &block
    str = "<div class=\"dark_card\" id=\"#{id}\" align=\"#{alignment.to_sym}\">"
    str << capture(&block)
    str << '</div>'
    raw str
  end

  def standard_card &block
    str = '<div class="card" align="center">'
    str << capture(&block)
    str << '</div>'
    raw str
  end

  def get_site_ico
    if anrcho?
      "anrcho"
    elsif raleigh_dsa?
      "dsa"
    elsif @bigger_bucks
      "story"
    elsif request.host.eql? "forrestonlyclub.com"
      "foc"
    elsif request.host.eql? "forrestwilkins.com" or request.host.eql? "forrestwebco.com" or dev? or (invited? and not current_user)
      "cube"
    elsif request.original_url.include? "/store"
      "store_2"
    else
      if current_user and not Rails.env.development?
        "bust"
      else
        "social_maya"
      end
    end
  end

  def justified_body item
    'justified_body_text' if (item.is_a?(Message) ? decrypt_message(item) : item.body).size > 125
  end

  def fa_icon icon, label='', size=''
    str = %Q[<i class="fa fa-#{icon}#{' ' + size if size.present?}"></i>] + " " + label
    return str.html_safe
  end

	def random_color as_str=nil
		rgb = []; 3.times { rgb << Random.rand(1..255) }
		rgb = "#{ rgb[0] }, #{ rgb[1] }, #{ rgb[2] }" if as_str
		return rgb
	end

  def rand_string
    SecureRandom.urlsafe_base64.gsub(/[^0-9a-z]/i, '')
  end

  def clean_a_token token
    return token.gsub(/[^0-9a-z]/i, '')
  end

  def time_ago(_time_ago)
    _time_ago = _time_ago + " ago"
    if _time_ago.include? "about"
    	_time_ago.slice! "about "
    end
    if _time_ago[0].to_i > 0 and _time_ago[1].to_i > 0
      _time_ago = _time_ago[0..2] + _time_ago[3.._time_ago.size]
    elsif _time_ago[0].to_i > 0
      _time_ago = _time_ago[0..1] + _time_ago[2.._time_ago.size]
    end
    return _time_ago
  end
end
