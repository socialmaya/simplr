class SettingsController < ApplicationController
  before_action :dev_only, only: [:dev_panel]
  
  def dev_panel
    if params[:invite_token]
      @invite = Connection.find_by_unique_token params[:invite_token]
      if @invite
        @invite_link = root_url; @invite_link.slice!(-1)
        @invite_link +=redeem_invite_path(@invite.unique_token)
      end
    end
  end
  
  def index
  end

  def update
    Setting.names.each do |category, names|
      for name in names
        if category.eql? :state and params[name.to_sym].present? or category.eql? :on or params[:restore_defaults]
          current_user.settings.find_by_name(name).update category => \
            (params[:restore_defaults] ? (category.eql?(:on) ? false : "") : params[name.to_sym])
        end
      end
    end
    redirect_to :back
  end
  
  private
  
  def dev_only
    dev?
  end
end
