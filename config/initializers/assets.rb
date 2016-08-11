# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )
Twilio.connect(ENV['TWILIO_SID'], ENV['TWILIO_AUTH_TOKEN'])
TWILIO_NUM = ENV['TWILIO_NUM']
MY_NUM = ENV['MY_NUM']
require 'openwfe/util/scheduler'
include OpenWFE
scheduler = Scheduler.new
scheduler.start
Launch.connection
scheduler.schedule_every('10s') { Launch.scrape_launches }

