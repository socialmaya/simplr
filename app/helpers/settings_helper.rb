module SettingsHelper
  def rgb_options setting, color
    # initializes options with nil color label
    options = [[color.to_s.upcase, nil]]
    # inserts rgb color range
    (0..255).each do |n|
      options << n
    end
    # replaces initial element if already set
    if settings[setting.to_sym].present?
      # strips string to just comma separated numbers
      rgb_str = settings[setting.to_sym][4..-2]
      # converts string to array of integers
      rgb_array = rgb_str.split(', ').map{|n| n.to_i}
      # gets relevant number from rgb array
      rgb_n = case color
      when :r
        rgb_array[0]
      when :g
        rgb_array[1]
      when :b
        rgb_array[2]
      end
      options[0] = ["#{color.to_s.upcase}:#{rgb_n}", rgb_n]
    end
    return options
  end
  
  def color_options
    [["Choose a color", nil],
    ['red', 'rgb(255, 0, 0)'],
    ['green', 'rgb(0, 255, 0)'],
    ['blue', 'rgb(0, 0, 255)'],
    ['purple', 'purple'],
    ['yellow', 'yellow'],
    ['pink', 'magenta']]
  end
end
