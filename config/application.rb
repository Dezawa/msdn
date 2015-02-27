require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Msdn
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :default

    config.time_zone = 'Tokyo'
    config.active_record.default_timezone = :local
  end
end

class Array
  def mult(other) ;  self.zip(other).map{ |a,b| a*b } ;end
  def add(other) ;  self.zip(other).map{ |a,b| a+b } ;end
  def sub(other) ;  self.zip(other).map{ |a,b| a-b } ;end
  def times(other) ;  self.map{ |a| a*other } ;end
end

