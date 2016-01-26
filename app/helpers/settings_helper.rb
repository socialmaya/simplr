module SettingsHelper
  def color_options
    options = [["Choose a color", nil]]
    colors = ['red', 'green', 'blue']
    for color in colors
      options << [color, color]
    end
    return options
  end
end
