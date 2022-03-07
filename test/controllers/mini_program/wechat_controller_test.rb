require "test_helper"
require "mocha/minitest"
require "minitest/unit"
require "net/http"

module MiniProgram
  class WechatControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    test "POST /wechat/login" do
      open_id = "abcd123"
      session_key = "fake_session_key"

      result = MiniProgram::ServiceResult.new(success: true, data: {
        "session_key" => session_key,
        "openid" => open_id
      })

      MiniProgram::Client.any_instance.expects(:login).returns(result)

      post wechat_login_url

      user = JSON.parse(@response.body)

      assert_response :success
      assert_equal open_id, user["open_id"]
      assert_equal session_key, user["session_key"]
    end

    test "POST /wechat/phone_num" do
      phone_num ="13022223333"

      mock_result = MiniProgram::ServiceResult.new(success: true, data: {
        "open_id" => "xxx",
        "phone_num" => phone_num
      })
      MiniProgram::Client.any_instance.expects(:decrypt_phone_num).returns(mock_result)

      post wechat_phone_num_url

      assert_response :success
      assert_equal phone_num, JSON.parse(@response.body)["phone_num"]
    end

  end
end
