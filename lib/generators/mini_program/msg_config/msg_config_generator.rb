class MiniProgram::MsgConfigGenerator < Rails::Generators::Base
  source_root File.expand_path('templates', __dir__)

  def create_subscribe_msg_config_file
    copy_file "subscribe_msg.yml", "config/subscribe_msg.yml"
  end
end
