
module MiniProgram
  class Msg
    attr_reader :msg_config, :type, :data
    def initialize(type, data)
      @type = type
      @data = data
    end

    def as_json
      {
        template_id: config[:template_id],
        data: JSON.parse(config[:data].to_json % data),
        page: config[:page],
      }
    end

    def send_to(open_id)
      mini_program.send_msg(self, to: open_id)
    end

    def mini_program
      @mini_program ||= MiniProgram::Client.new
    end

    def config
      @config ||= YAML.load_file(Rails.root.join("config/subscribe_msg.yml")).with_indifferent_access[type]
    end
  end
end