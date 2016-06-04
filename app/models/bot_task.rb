class BotTask < ActiveRecord::Base
  belongs_to :bot
  
  def self.task_types
    { reset_table: 'Reset Tables - (╯°□°)╯︵ ┻━┻  ... ┬─┬﻿ ノ( ゜-゜ノ)' }
  end
  
  private
    def gen_unique_token
      self.unique_token = SecureRandom.urlsafe_base64
    end
end
