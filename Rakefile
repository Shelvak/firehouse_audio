require 'rake'
require 'rubygems'
require 'bundler/setup'
require 'redis'
require 'bugsnag'
require 'byebug'
require 'time'
require 'json'

require File.expand_path('../lib/audio_player', __FILE__)
require File.expand_path('../lib/helpers', __FILE__)

$lib_path = File.expand_path('..', __FILE__)
$REDIS_HOST = ENV['REDIS_HOST'] || ENV['REDIS_PORT_6379_TCP_ADDR'] || 'localhost'
BROADCAST_IP = ENV['BROADCAST_IP'] || '10.0.10.255'

task default: [:start]

desc 'Run Console'
task :console do
  require 'irb'
  require 'irb/completion'
  ARGV.clear
  $stdout.sync = true

  IRB.start
end

desc 'Start application [Default]'
task :start do
  Bugsnag.configure do |config|
    config.api_key = ENV['BUGSNAG_KEY']
  end

  AudioPlayer.start

  exit 1
end
