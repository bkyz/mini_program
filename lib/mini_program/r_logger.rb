module MiniProgram
  class RLogger
    def initialize
      raise Exceptions::InitializeDenied.new("please use 'RLogger.make' instead of 'RLogger.new'")
    end

    class << self
      def make(given_filename)
        filename = log_filename(given_filename)

        # 如果已经存在日志对象，则返回已有的日志对象
        logger = Logger.new(filename)
        ActiveSupport::TaggedLogging.new(logger)
      end

      def log_filename(given_filename)
        return STDOUT if ENV["RAILS_LOG_TO_STDOUT"].present?

        if given_filename.class.in? [String, Symbol]
          unless given_filename.end_with? ".log"
            given_filename = "#{given_filename}.log"
          end

          Rails.root.join("log/#{given_filename}")
        elsif given_filename.respond_to? :to_path
          given_filename.to_path
        else
          raise Exception::UnsupportedParamType.new("\"log filename parameter must be a String type or a Symbol\"")
        end
      end
    end

  end
end
