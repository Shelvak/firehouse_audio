module Helpers
  class << self
    @@logs_path = nil

    def log(string)
      `echo "#{time_now} => #{string}" >> #{logs_path}/audioplayer.log`
    end

    def error(string, ex)
      msg = [
        time_now,
        string,
        ex.message,
        "\n" + ex.backtrace.join("\n")
      ].join(' => ')

      `echo -en "#{msg}" >> #{logs_path}/audioplayer.errors`
    end

    def time_now
      # Argentina Offset
      (Time.now.utc - 10800).strftime('%H:%M:%S')
    end

    def logs_path
      return @@logs_path if @@logs_path

      @@logs_path = ENV['logs_path']
      @@logs_path ||= if File.writable_real?('/logs')
                        '/logs'
                      else
                        logs_path = File.join($lib_path, '..', 'logs')
                        system("mkdir -p #{logs_path}")

                        logs_path
                      end
    end
  end
end
