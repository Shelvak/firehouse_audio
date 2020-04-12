module AudioPlayer
  module Helpers
    module_function

    LOGGER_FORMATTER = proc do |severity, datetime, progname, msg|
      [
        (datetime.utc + Time.zone_offset('-0300').to_i).strftime('%Y-%m-%d %H:%M:%S'),
        "[#{severity}]",
        msg,
        "\n"
      ].join ' '
    end


    def log(string = '')
      logger.info string
    rescue => ex
      error(string, ex)
    end

    def error(string, ex=nil)
      ex = string if string.is_a?(Exception)
      report_error(ex)

      error_logger.error(string)
      if ex
        error_logger.error(ex)
        error_logger.error(ex.backtrace.join("\n")) rescue nil # just in case
      end
    end

    def report_error(error)
      ::Bugsnag.notify(error)
    end

    def logger
      @logger ||= begin
                    logger = ::Logger.new(logs_path + '/audioplayer.log', 10, 10_485_760) # keep 10, 10Mb
                    logger.formatter = LOGGER_FORMATTER
                    logger
                  end
    end

    def error_logger
      @error_logger ||= begin
                    logger = ::Logger.new(logs_path + '/audioplayer_error.log', 10, 10_485_760) # keep 10, 10Mb
                    logger.formatter = LOGGER_FORMATTER

                    logger
                  end
    end


    def redis
      @redis_opts ||= begin
                        opts = {
                          host: ENV['REDIS_HOST'] || ENV['REDIS_PORT_6379_TCP_ADDR'] || 'localhost',
                          port: ENV['REDIS_PORT'] || '6379'
                        }
                        opts.merge!(password: ENV['REDIS_PASS']) if ENV['REDIS_PASS']
                        opts
                      end

      Redis.new(@redis_opts)
    end

    def time_now
      # Argentina Offset
      Time.now.utc + Time.zone_offset('-0300').to_i
    end


    def logs_path
      logs = ENV['LOGS_PATH']
      logs ||= if File.writable_real?('/logs')
                 '/logs'
               else
                 File.expand_path('../../logs', __FILE__)
               end
      system("mkdir -p #{logs}")
      logs
    end

    def thread
      name = caller_name(caller[0])

      $threads[name]&.kill rescue nil

      log("[THREAD] Starting #{name}")

      t = Thread.new { yield }

      $threads[name] = t

      t
    end

    def before_retry(e)
      Helpers.error(e)
      sleep 2
      Helpers.log "RETRYING: #{caller_name caller[1]} (#{e})"
    end

    def caller_name(name)
      klass, method_name = *name.split("/").last.scan(/(.*)\.rb.*:in `(.*)'/).flatten
      "#{klass&.capitalize}.#{method_name}"
    end
  end
end
