require "test_helper"

class ActionControllerBase < ActionDispatch::IntegrationTest
  include MiniProgram::Engine.routes.url_helpers

  test "should return mp user" do 
    my_cookies = ActionDispatch::Request.new(Rails.application.env_config.deep_dup).cookie_jar
    my_cookies.signed[:open_id] = "abcd123"
    my_cookies.signed[:phone_num] = "13011221122"
    my_cookies.signed[:nickname] = "faker"

    cookies[:open_id] = my_cookies[:open_id]
    cookies[:phone_num] = my_cookies[:phone_num]
    cookies[:nickname] = my_cookies[:nickname]
    
    resp = get "demo/index"
    p resp
  end
end
