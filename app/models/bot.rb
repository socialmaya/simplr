class Bot < ActiveRecord::Base
  belongs_to :user
  belongs_to :bot
  has_many :bots, dependent: :destroy
  has_many :bot_tasks, dependent: :destroy
  has_many :comments, dependent: :destroy
  
  
  before_create :gen_uniqueness

  mount_uploader :image, ImageUploader
  
  def self.manifest_bots tasks=[], items={}
    for task in tasks
      if Bot.available_for_task? task
        bot = Bot.next_up_for_task task
        case task
        when :reset_table
          comments = items[:comments]
          if comments.present? and comments.last.body.include? "(╯°□°)╯︵ ┻━┻"
            comment = comments.new bot_id: bot.id, body: "┬─┬﻿ ノ( ゜-゜ノ)"
            comment.save
          end
        when :grow
          # sets bot to currently growing at given page
          _task = bot.bot_tasks.find_by_name(task.to_s)
          if _task and _task.update currently_running: true
            bot.page = items[:controller] + " " + items[:action]
            bot.save
          end
          # bot needs to join with another at same page
        end
      end
    end
  end
  
  # the next availbe bot for the given task
  def self.next_up_for_task task_name
    bots_with_task = []
    for bot in Bot.all
      task = bot.bot_tasks.find_by_name task_name.to_s
      bots_with_task << bot if task and not task.currently_running
    end
    return bots_with_task.last
  end

  # if any bots are currently available for the given task
  def self.available_for_task? task_name
    available = false
    for bot in Bot.all
      task = bot.bot_tasks.find_by_name task_name.to_s
      if task and not task.currently_running
        available = true
      end
    end
    return available
  end
  
  private
    def gen_uniqueness
      gen_unique_token
      gen_unique_bot_name
    end
    
    # sets a generic bot name for bot unless named by user
    def gen_unique_bot_name
      unless self.name.present?
        self.name = "bot_" + self.unique_token
      end
    end
    
    def gen_unique_token
      self.unique_token = SecureRandom.urlsafe_base64
    end
end
