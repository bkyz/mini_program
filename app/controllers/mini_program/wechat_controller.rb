require_dependency "mini_program/application_controller"

module MiniProgram
  class WechatController < ApplicationController
    skip_forgery_protection if respond_to? :skip_forgery_protection

    # POST /wechat/login
    def login
      result = MiniProgram::Client.new.login(params["code"])

      if result.success?
        cookies.signed[:openid] = result.data["openid"]
        cookies.signed[:session_key] = result.data["session_key"]
        cookies.signed[:options] = params[:options].permit!

        after_mp_login if respond_to? :after_mp_login

        render json: current_mp_user
      else
        render json: { error: result.error }
      end
    end

    # POST /wechat/phone_num
    def phone_num
      client = MiniProgram::Client.new
      result = client.get_phone_num(code: params[:code], encrypted_data: params[:encrypted_data], iv: params[:iv])

      if result.success?
        cookies.signed[:phone_num] = result.data[:phone_num]

        render json: result.data
      else
        render json: { error: result.error }
      end
    end
  end
end
