class BotsController < ApplicationController
  before_action :invite_only
  before_action :bots_to_404
  before_action :dev_only
  
  def my_bots
    @user = User.find_by_id params[:id]
    @bots = Bot.where(user_id: @user.id) if @user
  end
  
  def index
    @bots = Bot.all.reverse
  end
  
  def show
    @bot = Bot.find_by_id params[:id]
  end
  
  def create
    @bot = Bot.new
    @bot.name = params[:bot_name]
    @bot.body = params[:bot_body]
    @bot.user_id = current_user.id
    if @bot.save
      params.each do |key, val|
        if key.include? "bot_task_"
          task = @bot.bot_tasks.new name: val
          # saves if there aren't any like tasks already assigned to bot
          task.save unless @bot.bot_tasks.find_by_name val
        end
      end
      redirect_to bot_path(@bot)
    else
      redirect_to :back
    end
  end
  
  private
    def dev_only
      redirect_to '/404' unless dev?
    end
    
    def bots_to_404
      redirect_to '/404' if request.bot?
    end
    
    def invite_only
      unless invited?
        redirect_to invite_only_path
      end
    end
end
