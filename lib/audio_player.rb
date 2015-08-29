module AudioPlayer
  class << self
    def start
      p 'Iniciando'
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
      redis.publish('start-broadcast', 'go on!')
    end

    def stop_broadcast!
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
      sleep 1

      params = %w(
        --play-and-exit
        --sout='#transcode{vcodec=none,acodec=mp3,ab=128,channels=2,samplerate=44100}:udp{dst=BROADCAST_IP:8000, mux=raw}'
        --no-sout-rtp-sap
        --no-sout-standard-sap
        --ttl=1
        --sout-keep
      ).join(' ').gsub('BROADCAST_IP', $FIREHOUSE_HOST)

      `su - vlc -c "cvlc #{file} #{params}"`
      sleep 1
    rescue => ex
      p 'Bombita rodrigues', ex
      Helpers.error 'Playing error: ', ex
    end
  end
end
