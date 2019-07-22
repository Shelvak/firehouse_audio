module AudioPlayer
  module Helpers
    extend self

    def log(string = '')
      logger.info string
    rescue => ex
      error(string, ex)
    end

    def error(string, ex=nil)
      ex = string if string.is_a?(Exception)
      report_error(ex)

      logger.error(string)
      if ex
        logger.error(ex)
        logger.error(ex.backtrace.join("\n"))
      end
    end

    def report_error(error)
      ::Bugsnag.notify(error)
    end

    def logger
      @logger ||= begin
                    logger = ::Logger.new(logs_path + '/audioplayer.log', 10, 10_485_760) # keep 10, 10Mb
                    logger.formatter = proc do |severity, datetime, progname, msg|
                      "#{(datetime.utc + Time.zone_offset('-0300').to_i).strftime('%Y-%m-%d %H:%M:%S')} [#{severity}] #{msg}\n"
                    end
                    logger
                  end
    end

    def redis
      @redis_opts ||= begin
                        opts = {
                          host: ENV['REDIS_HOST'] || ENV['REDIS_PORT_6379_TCP_ADDR'] || 'localhost',
                          port: ENV['REDIS_PORT'] || '6379'
                        }
                        # opts.merge!(password: ENV['REDIS_PASS']) if ENV['REDIS_PASS']
                        opts
                      end

      Redis.new(@redis_opts)
    end

    def time_now
      # Argentina Offset
      Time.now.utc - 10800
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
  end
end
