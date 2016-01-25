class Setting < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :name
  
  def self.names
    { on: ['bg_fader_on'],
      state: ['bg_color', 'post_card_color'] }
  end
end
