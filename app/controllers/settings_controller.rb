class SettingsController < ApplicationController
  def index
  end

  def update
    Setting.names.each do |category, names|
      for name in names
        current_user.settings.find_by_name(name).update category => params[name.to_sym]
      end
    end
    redirect_to :back
  end
end
