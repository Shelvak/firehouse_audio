require 'rake'
require 'rubygems'
require 'bundler/setup'
require 'redis'
require 'bugsnag'
require 'pry-nav'

require File.expand_path('../lib/audio_player', __FILE__)
require File.expand_path('../lib/helpers', __FILE__)

Bugsnag.configure do |config|
   config.api_key = '3d5e73415ee46de2a3ef87b4d6b55a95'
end

$REDIS_HOST = ENV['REDIS_PORT_6379_TCP_ADDR'] || 'localhost'

AudioPlayer.start
