module ApplicationHelper
  def justified_body item
    'justified_body_text' if item.body.size > 150
  end
  
  def fa_icon icon, label=''
    str = %Q[<i class="fa fa-#{icon}"></i>] + " " + label
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
