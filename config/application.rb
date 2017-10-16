require File.expand_path('../boot', __FILE__)

require 'rails/all'

require 'carrierwave'
require 'carrierwave/orm/activerecord'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Simplr
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    
    config.web_console.development_only = false
    WebConsole::Colors.register_theme(:custom) do |c|
      # The most common color themes are the 16 colors one. They are built from 3
      # parts.
      # 8 darker colors.
      c.add '#000000'
      c.add '#cd0000'
      c.add '#00cd00'
      c.add '#cdcd00'
      c.add '#0000ee'
      c.add '#cd00cd'
      c.add '#00cdcd'
      c.add '#e5e5e5'
      # 8 lighter colors.
      c.add '#7f7f7f'
      c.add '#ff0000'
      c.add '#00ff00'
      c.add '#ffff00'
      c.add '#5c5cff'
      c.add '#ff00ff'
      c.add '#00ffff'
      c.add '#ffffff'
      # Background and foreground colors.
      c.background '#ffffff'
      c.foreground '#000000'
    end
    # Now you have to tell Web Console to actually use it.
    config.web_console.style.colors = :custom
    
    

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true
    
    # for loading custom libraries
    config.autoload_paths += %W(#{config.root}/lib)
    config.autoload_paths += Dir["#{config.root}/lib/**/"]
  end
end
