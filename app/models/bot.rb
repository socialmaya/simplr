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
            bot.page = [items[:controller], items[:action], items[:id]].to_s
            bot.save
          end
          # bot joins with another growing bot if present on same page and compatible
          other_bot = bot.currently_running_same_task_nearby task
          compatibility = bot.determine_compatibility other_bot
          if compatibility[:compatible]
            parent_bot = Bot.find_by_id compatibility[:parent_id]
            # creates baby bot on same page and with tokens pointing back to both parents
            baby_bot = parent_bot.bots.new page: parent_bot.page, parent_tokens: compatibility[:parent_tokens]
            if baby_bot.save
              # starts baby bot off with same task
              baby_bot.bot_tasks.create name: "grow"
            end
          end
        end
      end
    end
  end
  
  # to determine parent compatibility
  def determine_compatibility bot
    # compatibility hash also contains the surname id
    compatibility = { compatible: false, parent_id: nil, parent_tokens: nil }
    if bot
      # gets number occurance counts (gender) for both bots
      self_count = self.gender; other_count = bot.gender
      # puts both in array for number occurance comparison
      both_counts = [self_count, other_count].sort
      # checks the difference for number occurance
      if (both_counts[0]...both_counts[1]).size >= 2
        compatibility[:compatible] = true
        # sets parent_tokens here for easier access above
        compatibility[:parent_tokens] = [self.unique_token, bot.unique_token].to_s
        # the parent with the largest occurance of numbers
        compatibility[:parent_id] = if self_count > other_count
          self.id
        else
          bot.id
        end
      end
    end
    return compatibility
  end
  
  def currently_running_same_task_nearby task_name
    # gets pool of bots currently running given task on same page
    currently_running = []
    for bot in Bot.all
      task = bot.bot_tasks.find_by_name task_name.to_s
      if task and task.currently_running and bot.page.present? and bot.page.eql? self.page
        currently_running << bot unless bot.eql? self
      end
    end
    # randomly chooses bot from pool and returns it
    return currently_running[rand(0...currently_running.size)]
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
  
  def children
    _children = []
    for child in Bot.where.not(parent_tokens: nil)
      _children << child if eval(child.parent_tokens).include? self.unique_token
    end
    return _children
  end
  
  def parents
    _parents = []
    for bot in Bot.all
      _parents << bot if self.parent_tokens.present? and eval(self.parent_tokens).include? bot.unique_token
    end
    return _parents
  end
  
  def mates
    _mates = []
    for child in self.children
      for parent in child.parents
        _mates << parent unless self.eql? parent
      end
    end
    return _mates
  end
  
  def gender
    self.unique_token.scan(/\d+/).count
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
