module MiniProgram
  class Client
    attr_reader :appid, :app_secret

    def initialize(appid: config.appid, app_secret: config.app_secret)
      @appid = appid
      @app_secret = app_secret

      if appid == 'your appid'
        warn "\e[33m" + "*" * 80 + "\e[0m"
        warn "\e[33m警告: 请将 config/initializer/mini_program.rb 中的 appid 修改成你实际的appid\e[0m"
        warn "\e[33m" + "*" * 80 + "\e[0m"
      end

      if app_secret == 'your app_secret'
        warn "\e[33m" + "*" * 80 + "\e[0m"
        warn "\e[33m警告: 请将 config/initializer/mini_program.rb 中的 app_secret 修改成你实际的app_secret\e[0m"
        warn "\e[33m" + "*" * 80 + "\e[0m"
      end
    end

    def get_access_token(fresh: false)
      access_token = Rails.cache.read(access_token_store_key)

      if access_token.present? && !fresh
        return MiniProgram::ServiceResult.new(success: true,
                                              data: { access_token: access_token },
                                              message: "获取 access token 成功",
                                              message_kind: :get_access_token_success)
      end

      result = request_access_token

      if result.success?
        Rails.cache.write(access_token_store_key,
                          result.data["access_token"],
                          expires_in: 1.5.hours.to_i,
                          race_condition_ttl: 10)

        result.message = "获取 access token 成功"
        result.message_kind = :get_access_token_success
      end

      yield result if block_given?

      result
    end

    # 调用微信 api 获取 access_token
    #
    # @return MiniProgram::ServiceResult
    def request_access_token
      api = "https://api.weixin.qq.com/cgi-bin/token"
      params = {
        appid: appid,
        secret: app_secret,
        grant_type: :client_credential
      }

      response = get(api, params)

      result = JSON.parse(response)

      if result["errcode"] && result["errcode"].to_s != "0"
        logger.tagged "request access token" do
          logger.error <<~ERROR
          Get access token failed.
          api: #{api} 
          error: #{result}
          ERROR
        end

        MiniProgram::ServiceResult.new(success: false,
                                       error: result,
                                       message: result["errmsg"],
                                       message_kind: :request_access_token_failed)
      else
        MiniProgram::ServiceResult.new(success: true,
                                       data: { access_token: result["access_token"] },
                                       message: "请求 access token 成功",
                                       message_kind: :request_access_token_success)
      end
    end

    # 调用微信授权登录 api
    #
    #
    def login(code)
      api = "https://api.weixin.qq.com/sns/jscode2session"
      params = {
        appid: appid,
        secret: app_secret,
        js_code: code,
        grant_type: :authorization_code
      }

      response = get(api, params)

      result = JSON.parse(response)

      if result["errcode"] && result["errcode"].to_s != "0"
        logger.tagged "login mini program"
        logger.error <<~ERROR
          Get session key failed.
          api: #{api}
          result: #{result}
        ERROR

        MiniProgram::ServiceResult.new(success: false,
                                       error: result,
                                       message: result["errmsg"],
                                       message_kind: :login_failed)

      else
        MiniProgram::ServiceResult.new(success: true,
                                       data: result,
                                       message: "小程序登录成功",
                                       message_kind: :login_success)
      end

    end

    # 发送订阅消息
    # @param [MiniProgram::Msg] msg
    # @param [String] to 用户的openid
    def send_msg(msg, to:)
      openid = to.try(:openid) || to

      payload = msg.as_json.merge!(touser: openid)

      # 获取 access_token
      get_token_result = get_access_token
      if get_token_result.failure?
        return get_token_result
      end

      api = "https://api.weixin.qq.com/cgi-bin/message/subscribe/send?access_token=#{get_token_result["access_token"]}"
      result = post(api, payload)

      if result["errcode"].to_s != "0"
        logger.tagged "Subscribe Message" do
          logger.error { "{params: #{payload}, response: #{result}}" }
        end

        MiniProgram::ServiceResult.new(success: false,
                                       error: result,
                                       message: "发送订阅消息失败",
                                       message_kind: :send_subscribed_message_failed)
      else
        logger.tagged "Subscribe Message" do
          logger.info { "{params: #{payload}, response: #{result}}" }
        end

        MiniProgram::ServiceResult.new(success: true,
                                       data: {
                                         msgid: result["msgid"]
                                       },
                                       message: "发送订阅消息成功",
                                       message_kind: :send_subscribed_message_success)
      end

    end

    # 「发送统一服务消息」
    # 统一服务消息原本是可以从调用小程序的 api ，通过用户小程序的 openid 发送模板消息到小程序和公众号那里去，
    # 现在小程序的模板消息功能关闭了，就只剩下发送模板消息到公众号这个功能了
    #
    def send_uniform_msg(msg, to:)
      openid = to.try(:openid) || to

      payload = msg.as_json

      get_token_result = get_access_token
      if get_access_token.failure?
        return get_token_result
      end

      api = "https://api.weixin.qq.com/cgi-bin/message/template/send?access_token=#{get_token_result["access_token"]}"
      result = post(api, {
        touser: openid,
        mp_template_msg: payload
      })

      if result["errcode"].to_s != "0"
        logger.tagged "uniform message" do
          logger.error { "{params: #{payload}, response: #{result}}" }
        end

        MiniProgram::ServiceResult.new(success: false,
                                       error: result,
                                       message: "发送统一服务消息失败",
                                       message_kind: :send_uniform_message_failed)
      else
        msg_logger.info { "{params: #{payload}, response: #{result}}" }
        MiniProgram::ServiceResult.new(success: true,
                                       data: result,
                                       message: "发送统一服务消息成功",
                                       message_kind: :send_uniform_message_success)
      end

    end

    # 获取用户手机号
    def decrypt_phone_num(code:, encrypted_data:, iv:)
      login_result = login(code)
      return login_result if login_result.failure?

      openid = login_result.data[:openid]
      session_key = login_result.data[:session_key]

      data = decrypt_phone_data(encrypted_data, iv, session_key)

      phone_num = JSON.parse(data)["phoneNumber"]

      MiniProgram::ServiceResult.new(
        success: true,
        message: "解密手机号成功",
        message_kind: :decrypt_phone_number_success,
        data: {
          openid: openid,
          phone_num: phone_num
        })
    rescue OpenSSL::Cipher::CipherError, ArgumentError => e
      MiniProgram::ServiceResult.new(
        success: false,
        message: "解密手机号失败",
        message_kind: :decrypt_phone_data_failed,
        error: e
      )
    end

    def config
      appid, app_secret = if MiniProgram.appid && MiniProgram.app_secret
                            [MiniProgram.appid, MiniProgram.app_secret]

                            # 如果有挂载 WechatPayment 的 engine 时，使用里边的小程序配置
                          elsif Object.const_defined? "WechatPayment"
                            [WechatPayment.sub_appid || WechatPayment.appid, WechatPayment.sub_app_secret || WechatPayment.app_secret]
                          else
                            [nil, nil]
                          end

      Struct.new(:appid, :app_secret).new(appid, app_secret)
    end

    #获取小程序二维码
    def qrcode_unlimited(scene:, page:, width: 280, check_path: true, env_version: "release")
      get_token_result = get_access_token.on_failure do |result|
        return result
      end

      api = "https://api.weixin.qq.com/wxa/getwxacodeunlimit?access_token=#{get_token_result["access_token"]}"

      params = { scene:, page:, width:, check_path:, env_version: }

      result = post(api, params)

      if result["errcode"]
        logger.error { "{ action: 'generate qrcode', params: #{params}, response: #{result}}" }
        MiniProgram::ServiceResult.new(success: false,
                                       error: result,
                                       message: "获取二维码失败",
                                       message_kind: :get_unlimited_qrcode_failed)
      else
        logger.info { "{ action: 'generate qrcode',  params: #{params}, response: #{result} }" }
        MiniProgram::ServiceResult.new(success: true,
                                       data: { image: result },
                                       message: "获取二维码成功",
                                       message_kind: :get_unlimited_qrcode_success)
      end
    end

    private

    def get(api, payload = {})
      uri = URI(api)

      if payload.present?
        uri.query = URI.encode_www_form(payload)
      end

      Net::HTTP.get(uri)
    end

    def post(api, payload = {}, options = {})
      uri = URI(api)

      req = Net::HTTP::Post.new(uri)
      req["Content-Type"] = "application/json"
      options = {
        use_ssl: true
      }.merge(options)

      res = Net::HTTP.start(uri.host, uri.port, **options) do |http|
        http.request(req, payload.to_json)
      end

      image_content_types = ["image/jpeg", "image/jpg", "image/gif", "image/png"]

      return res.body if res["Content-Type"].in? image_content_types

      JSON.parse(res.body)
    end

    def decrypt_phone_data(encrypted_data, iv, session_key)
      aes = OpenSSL::Cipher::AES.new "128-CBC"
      aes.decrypt
      aes.key = Base64::decode64(session_key)
      aes.iv = Base64.decode64(iv)
      aes.update(Base64::decode64(encrypted_data)) + aes.final
    end

    def logger
      @logger ||= MiniProgram::RLogger.make("mini_program")
    end

    def access_token_store_key
      @access_token_store_key ||= "mp-#{appid}-access-token"
    end

    def msg_logger
      @msg_logger ||= MiniProgram::RLogger.make("wx_msg")
    end

  end
end
