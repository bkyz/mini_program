class MiniProgram::InstallGenerator < Rails::Generators::Base
  source_root File.expand_path('templates', __dir__)
  def create_initializer_file
    # copy_file "initializer.rb", "config/initializers/mini_program.rb"
    appid = if Object.const_defined? "WechatPayment"
              WechatPayment.sub_appid || WechatPayment.appid || "your appid"
            else
              "your appid"
            end

    app_secret = if Object.const_defined? "WechatPayment"
                   WechatPayment.sub_app_secret || WechatPayment.app_secret || "your app secret"
                 else
                   "your app_secret"
                 end
    create_file "config/initializers/mini_program.rb", <<~INITIALIZER

MiniProgram.setup do |config|
  config.appid = "#{appid}"
  config.app_secret = "#{app_secret}"
end
    INITIALIZER
  end
end
