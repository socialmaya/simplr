class Bot < ActiveRecord::Base
  belongs_to :user
  has_many :bot_tasks, dependent: :destroy
  has_many :comments, dependent: :destroy
  
  before_create :gen_uniqueness

  mount_uploader :image, ImageUploader
  
  def self.manifest_bots tasks=[], items={}
    for task in tasks
      if Bot.exists_with_task? task
        bot = Bot.last_with_task task
        case task
        when :reset_table
          comments = items[:comments]
          if comments.present? and comments.last.body.include? "(╯°□°)╯︵ ┻━┻"
            comment = comments.new bot_id: bot.id, body: "┬─┬﻿ ノ( ゜-゜ノ)"
            comment.save
          end
        end
      end
    end
  end
  
  def self.last_with_task task
    bots_with_task = []
    for bot in Bot.all
      bots_with_task << bot if bot.bot_tasks.find_by_name task.to_s
    end
    return bots_with_task.last
  end

  def self.exists_with_task? task
    exists_with_task = false
    for bot in Bot.all
      if bot.bot_tasks.find_by_name task.to_s
        exists_with_task = true
      end
    end
    return exists_with_task
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
