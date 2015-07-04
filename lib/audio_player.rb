module AudioPlayer
  class << self
    def start
      p "Iniciando"
      redis.subscribe('interventions:play_audio_file') do |on|
        on.message do |channel, file_path|
          p 'mensaje', file_path

          play_file full_file_path_for(file_path)
        end
      end
    end

    def redis
      Redis.new(host: $REDIS_HOST)
    end

    def full_file_path_for(file_path)
      father = ENV['firehouse_path'] || File.expand_path('..', __FILE__)

      File.join(father, file_path)
    end

    def play_file(file)
      begin
        raise "File not found #{file}" unless File.exist?(file)

        Helpers.log "Playing file: #{file}"

        `mplayer -noconsolecontrols -quiet #{file} &`
      rescue => ex
        p 'Bombita rodrigues', ex
        Helpers.error 'Playing error: ', ex
      end
    end
  end
end
