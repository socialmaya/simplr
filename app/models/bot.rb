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
      # initializes any bots standing idle for task (no page presence)
      Bot.idle_for_task(task, items[:page].to_s).each do |bot|
        _task = bot.bot_tasks.find_by_name(task.to_s)
        _task.update page: items[:page].to_s if _task
      end
      # if any bots are ready for task on given page 
      if BotTask.where(name: task, page: items[:page].to_s).present?
        # needs to get array of bots ready for task on page
        # and ability to get certain number of random bots from array
        # needs to account for number of bots required for particular tasks
        case task
        when :reset_table
          comments = items[:comments]
          if comments.present? and comments.last.body.include? "(╯°□°)╯︵ ┻━┻"
            comment = comments.new bot_id: bot.id, body: "┬─┬﻿ ノ( ゜-゜ノ)"
            comment.save
          end
        when :grow
          # bot joins with another growing bot if present on same page and compatible
          other_bot = bot.currently_running_same_task_nearby task
          compatibility = bot.determine_compatibility other_bot
          if compatibility[:compatible]
            parent_bot = Bot.find_by_id compatibility[:parent_id]
            # potential to spawn more than one child bot
            rand(1..2).times do
              # creates baby bot with tokens pointing back to both parents
              baby_bot = parent_bot.bots.new parent_tokens: compatibility[:parent_tokens]
              if baby_bot.save
                # starts baby bot off with same task
                baby_bot.bot_tasks.create name: "grow"
              end
            end
          end
        end
      end
    end
  end
  
  def self.idle_for_task task_name, page
    idle = []
    for bot in Bot.all
      task = bot.bot_tasks.find_by_name task_name
      unless task.page.present?
        idle << bot
      end
    end
    return idle
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
      if (both_counts[0]...both_counts[1]).size >= 2 and not self.related? bot
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
  
  def related? other_bot
    related = false
    [:children, :parents, :siblings].each do |sym|
      if self.send(sym).include? other_bot
        related = true
      end
    end
    return related
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
  
  def siblings
    _siblings = []
    for parent in self.parents
      for child in parent.children
        unless _siblings.include? child or self.eql? child
          _siblings << child
        end
      end
    end
    return _siblings
  end
  
  def mates
    _mates = []
    for child in self.children
      for parent in child.parents
        unless _mates.include? parent or self.eql? parent
          _mates << parent
        end
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
