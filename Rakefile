require 'rake'
require 'rubygems'
require 'bundler/setup'
require 'redis'
require 'bugsnag'
require 'pry-nav'

require File.expand_path('../lib/audio_player', __FILE__)
require File.expand_path('../lib/helpers', __FILE__)

Bugsnag.configure do |config|
   config.api_key = ENV['BUGSNAG_KEY']
end

$lib_path = File.expand_path('..', __FILE__)
$REDIS_HOST = ENV['REDIS_HOST'] || ENV['REDIS_PORT_6379_TCP_ADDR'] || 'localhost'
BROADCAST_IP = ENV['BROADCAST_IP'] || '10.0.10.255'

AudioPlayer.start
