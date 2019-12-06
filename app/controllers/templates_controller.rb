class TemplatesController < ApplicationController
  before_action :set_templating, only: [:semantic_ui, :uikit, :purecss, :sample_blog]
  before_action :set_bigger_bucks, only: [:bigger_bucks, :admin, :login, :edit, :update]

  before_action :set_item, only: [:edit, :update]
  before_action :check_auth, only: [:edit, :update]

  layout :resolve_layout

  def update
    if @item.update(body: params[:body])
      redirect_to bigger_bucks_path
    else
      redirect_to :back, notice: "Failed to update item..."
    end
  end

  def index
    @forrest_web_co = true
  end

  def semantic_ui
    @semantic_ui = @forrest_web_co = true
  end

  private

  def check_auth
    redirect_to '/404' unless current_user
  end

  def set_item
    @item = TemplateItem.find_by_unique_token params[:token]
  end

  def resolve_layout
    case action_name.to_sym
    when :bigger_bucks, :admin, :login, :edit
      "bigger_bucks"
    else
      "application"
    end
  end

  def set_bigger_bucks
    @bigger_bucks = true
  end

  def set_templating
    @templating = true
  end
end
