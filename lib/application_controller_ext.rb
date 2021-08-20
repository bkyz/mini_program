

ActionController::Base.class_eval do 
  def current_mp_user
    MiniProgram::User.new(open_id: cookies.signed[:open_id],
                          nickname: cookies.signed[:nickname],
                          phone_num: cookies.signed[:phone_num],
                          session_key: cookies.signed[:session_key])
  end
end
