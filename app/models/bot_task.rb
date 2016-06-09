class BotTask < ActiveRecord::Base
  belongs_to :bot
  
  validate :named?, on: :create
  
  def self.task_types
    { reset_table: 'Reset Tables - (╯°□°)╯︵ ┻━┻  ... ┬─┬﻿ ノ( ゜-゜ノ)',
      multiply: 'Multiply - Enable bot to reproduce with other bots',
      learn: 'Collect Data - Collect or gather data from users' }
  end
  
  private
    def named?
      unless self.name.present?
        errors.add :bot_task, "must be named."
      end
    end
    
    def gen_unique_token
      self.unique_token = SecureRandom.urlsafe_base64
    end
end
