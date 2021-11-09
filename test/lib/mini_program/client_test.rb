require "test_helper"
require "minitest/unit"
require "mocha/minitest"

class MiniProgram::ClientTest < ActiveSupport::TestCase
  test "#request_access_token" do

  end

  test "#get_access_token with cache (default)" do
    access_token = "access token"

    mock_result = MiniProgram::ServiceResult.new(success: true, data: {
      "access_token"=> access_token,
      "expires_in"=>7200
    })
    MiniProgram::Client.any_instance.expects(:request_access_token).returns(mock_result)

    client = MiniProgram::Client.new

    # clear cache
    access_token_store_key = client.send :access_token_store_key
    Redis.current.del(access_token_store_key)

    result = client.get_access_token
    assert_equal access_token, result.data["access_token"]
    # second fetch in cache
    assert_equal access_token, client.get_access_token.data["access_token"]
  end

  test "#get_access_token without cache" do
    first_access_token = "first token"
    second_access_token = "second token"

    first_mock_result = MiniProgram::ServiceResult.new(success: true, data: {
      "access_token"=> first_access_token,
      "expires_in"=>7200
    })

    second_mock_result = MiniProgram::ServiceResult.new(success: true, data: {
      "access_token"=> second_access_token,
      "expires_in"=>7200
    })

    # invoke twice
    MiniProgram::Client.any_instance.expects(:request_access_token).returns(second_mock_result)
    MiniProgram::Client.any_instance.expects(:request_access_token).returns(first_mock_result)

    client = MiniProgram::Client.new

    result = client.get_access_token(fresh: true)
    assert_equal first_access_token, result.data["access_token"]

    assert_equal second_access_token, client.get_access_token(fresh: true).data["access_token"]
  end

  test "#get_phone_num on get session key success" do
    phone_num = "13071511222"
    MiniProgram::Client.any_instance.expects(:decrypt_phone_data).returns({"phoneNumber"=>phone_num,
                                                                           "purePhoneNumber"=>phone_num,
                                                                           "countryCode"=>"86",
                                                                           "watermark"=>{"timestamp"=>1629447675, "appid"=>"wxb421faker51a412"}}.to_json)
    MiniProgram::Client.any_instance.expects(:login).returns(
      MiniProgram::ServiceResult.new(success: true, data: {
        session_key: "xxx",
        openid: "fake openid"
      })
    )

    result = MiniProgram::Client.new.get_phone_num(encrypted_data: "placeholder", iv: "placeholder", code: "placeholder")

    assert_equal phone_num, result.data["phone_num"]
  end

  test "#get_phone_num on get session key failed" do
    mock_result = MiniProgram::ServiceResult.new(success: false, data: {}, errors: { "errmsg" => "some errors occur" }, message: "some errors occur")
    MiniProgram::Client.any_instance.expects(:login).returns(mock_result)

    result = MiniProgram::Client.new.get_phone_num(encrypted_data: "placeholder", iv: "placeholder", code: "placeholder")

    assert_equal mock_result, result
  end
end