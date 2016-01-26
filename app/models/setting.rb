class Setting < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :name
  
  def self.names
    { on: ['bg_fader_on'],
      state: ['bg_color', 'post_bg_color', 'post_txt_color'] }
  end
end
