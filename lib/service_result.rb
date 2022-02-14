module MiniProgram
  class ServiceResult
    attr_accessor :success,
                  :error,
                  :data,
                  :message,
                  :message_kind,
                  :message_type

    delegate :[], :[]=, to: :data

    def initialize(success: false,
                   error: nil,
                   message: nil,
                   message_type: nil,
                   message_kind: nil,
                   data: {})

      self.success = success
      self.data = (data.presence || {}).with_indifferent_access
      self.error = error
      self.message = message
      self.message_type = message_type
      self.message_kind = message_kind
    end

    alias success? :success

    def failure?
      !success?
    end

    def on_success
      yield(self) if success?
      self
    end

    def on_failure
      yield(self) if failure?
      self
    end

    def get_message_type
      if message_type.present?
        message_type.to_sym
      elsif success?
        :notice
      else
        :error
      end
    end

    def as_json(options = nil)
      {
        success:,
        data:,
        message:,
        message_type: get_message_type,
        message_kind:,
        error:,
      }
    end
  end
end
