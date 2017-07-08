module AudioPlayer
  class << self
    def start
      p 'Iniciando'

      p "BROAD IP"
      p BROADCAST_IP
      p 'Force stop subscribe'
      force_stop_playing

      p 'Play audio subscribe'
      play_audio_file_subscribe!
    end

    def force_stop_playing
      Thread.new { force_stop_playing! }
    end

    def force_stop_playing!
      redis.subscribe('force-stop-broadcast') do |on|
        on.message do |_, msg|
          Helpers.log 'Forcing stop broadcast...'
          `killall vlc`
        end
      end
    end

    def play_audio_file_subscribe!
      redis.subscribe('interventions:play_audio_file') do |on|
        on.message do |_, file_path|
          p 'mensaje', file_path

          p 'Starting broadcast'
          start_broadcast!
          p 'Playing'
          play_file full_file_path_for(file_path)
          p 'Stoping'
          stop_broadcast!
        end
      end
    end

    def start_broadcast!
      Helpers.log 'Starting broadcast...'
      redis.publish('start-broadcast', 'go on!')
    end

    def stop_broadcast!
      Helpers.log 'Stoping broadcast...'
      redis.publish('stop-broadcast', 'die!')
    end

    def redis
      Redis.new(host: $REDIS_HOST)
    end

    def full_file_path_for(file_path)
      father = ENV['firehouse_path'] || File.expand_path('..', __FILE__)

      File.join(father, file_path)
    end

    def play_file(file)
      fail "File not found #{file}" unless File.exist?(file)

      Helpers.log "Playing file: #{file}"
      params = %w(
        --play-and-exit
        --sout='#transcode{vcodec=none,acodec=mp3}:udp{dst=BROADCAST_IP:8000, mux=raw, caching=10}'
        --no-sout-rtp-sap
        --no-sout-standard-sap
        --ttl=1
        --sout-keep
        --sout-mux-caching=10
      ).join(' ').gsub('BROADCAST_IP', BROADCAST_IP)

      Helpers.log "Exec #{params}"

      `cvlc #{file} #{params}`
      sleep 1
    rescue => ex
      p 'Bombita rodrigues', ex
      Helpers.error 'Playing error: ', ex
    end
  end
end
