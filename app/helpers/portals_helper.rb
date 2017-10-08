module PortalsHelper
  def portal_life_durations
    options = [["How long should it stay open for?", nil],
      ["1 week (default)", 7],
      ["1 month", 30],
      ["2 months", 60],
      ["3 months", 90]]
    return options
  end
end
