class BotTask < ActiveRecord::Base
  belongs_to :user
  
  def self.task_types
    { reset_table: 'Reset Tables - (╯°□°)╯︵ ┻━┻  ... ┬─┬﻿ ノ( ゜-゜ノ)' }
  end
end
