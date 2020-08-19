module AudioPlayer
  module_function

  $threads = {}
  Thread.abort_on_exception = true

  def start
    Helpers.log('Iniciando')

    force_stop_playing

    subscribe_test_channel

    play_audio_file_subscribe!
  rescue => e
    Helpers.error(e) rescue nil # just in case

    $threads.each do |name, t|
      Helpers.log "Killing thread: #{name}"
      t.kill rescue nil
      Helpers.log "Killed thread: #{name}"
    end
    $threads = {}

    Helpers.log "Retrying"
    retry
  end

  def force_stop_playing
    Helpers.thread { force_stop_playing! }
  rescue => e
    Helpers.before_retry(e)
    retry
  end

  def force_stop_playing!
    Helpers.redis.subscribe('force-stop-broadcast') do |on|
      on.message do |_, msg|
        Helpers.log 'Forcing stop broadcast...'
        `killall -q vlc`
        `killall -q cvlc`
      end
    end
  rescue => e
    Helpers.before_retry(e)
    retry
  end

  def subscribe_test_channel
    Helpers.thread { subscribe_test_channel! }
  rescue => e
    Helpers.before_retry(e)
    retry
  end

  def subscribe_test_channel!
    Helpers.redis.subscribe('services-test:audio') do |on|
      on.message do |_, msg|
        # La idea de esto es recibir un msg del tipo { channel: 'consume-123123123', message: 'PING' }
        parsed = JSON.parse(msg) rescue {}
        Helpers.log "Received test msg: #{msg} responding to #{parsed['channel']}: PONG"

        Helpers.redis.publish(parsed['channel'], 'PONG')
      end
    end
  rescue => e
    Helpers.before_retry(e)
    retry
  end

  def play_audio_file_subscribe!
    Helpers.log "Starting AudioPlayer.play_audio_file_subscribe!"

    Helpers.redis.subscribe('interventions:play_audio_file') do |on|
      on.message do |_, file_path|
        Helpers.log "Received msg: #{file_path}"

        play_file full_file_path_for(file_path)
      end
    end
  rescue => e
    Helpers.before_retry(e)
    retry
  end

  def full_file_path_for(file_path)
    father = ENV['firehouse_path'] || File.expand_path('..', __FILE__)

    File.join(father, file_path)
  end

  def play_file(file)
    unless File.exist?(file)
      Helpers.log "File not found #{file}"
      return
    end

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
  rescue => ex
    p 'Bombita rodrigues', ex
    Helpers.error 'Playing error: ', ex
  end
end
