module MiniProgram
  class RLogger
    def initialize
      raise Exceptions::InitializeDenied.new("please use 'ILogger.make' instead of 'ILogger.new'")
    end

    class << self
      def make(log_file)
        @logger ||= {}

        log_file_name = if log_file.class.in? [String, Symbol]
                          log_file_name = log_file.to_sym

                          unless log_file_name.to_s.end_with? ".log"
                            log_file_name = "#{log_file_name}.log"
                          end

                          "#{root_path}/#{log_file_name}"
                        elsif log_file.respond_to? :to_path
                          log_file.to_path
                        else
                          raise Exceptions::UnsupportdParamType.new("log file parameter only support 'File' or 'String' Type.")
                        end

        # 如果已经存在日志对象，则返回已有的日志对象
        @logger[log_file_name] ||= ::Logger.new(log_file_name)
      end

      def root_path
        @root ||= "#{Rails.root}/log"
      end
    end


  end
end
