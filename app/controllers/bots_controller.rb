class BotsController < ApplicationController
  def show
    @bot = User.find_by_id params[:id]
  end
  
  def create
    @bot = Bot.new
    @bot.name = params[:bot_name]
    @bot.body = params[:bot_body]
    if @bot.save!
      params.each do |key, val|
        if key.include? "bot_task_"
          task = @bot.bot_tasks.new name: val
          task.save
        end
      end
      redirect_to show_bot_path(@bot)
    else
      redirect_to :back
    end
  end
end
