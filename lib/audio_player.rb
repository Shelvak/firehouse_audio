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
        --sout='#transcode{vcodec=none,acodec=mp3,ab=96,channels=1,samplerate=11025}:udp{dst=192.168.1.255:8000, mux=raw}'
        --no-sout-rtp-sap
        --no-sout-standard-sap
        --ttl=1
        --sout-keep
      )

      `su - vlc -c "cvlc #{file} #{params.join(' ')}"`
      sleep 2
    rescue => ex
      p 'Bombita rodrigues', ex
      Helpers.error 'Playing error: ', ex
    end
  end
end
