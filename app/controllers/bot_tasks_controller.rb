class BotTasksController < ApplicationController
  # adds task field to bot form
  def add_task
    session[:task_field] = session[:task_field].to_i + 1
  end
  
  def show
    @bot = User.find_by_id params[:user_id]
  end
  
  def create_bot
    @bot = User.new bot: true
    @bot.name = params[:bot_name]
    @bot.body = params[:bot_body]
    if @bot.save
      params.each do |key, val|
        if key.include? "bot_task_"
          task = @bot.bot_tasks.new name: key
          task.save
        end
      end
    end
    redirect_to :back
  end
end
