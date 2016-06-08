class BotsController < ApplicationController
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
    if @bot.save!
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
end
