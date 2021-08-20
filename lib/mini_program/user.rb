
class MiniProgram::User
  attr_accessor :open_id, :nickname, :phone_num, :session_key
 
  def initialize(open_id: :blank_open_id,
                 nickname: :blank_nickname,
                 phone_num: :blank_phone_num,
                 session_key: :blank_session_key)
    @open_id = open_id
    @nickname = nickname
    @phone_num = phone_num
    @session_key = session_key
  end
end
