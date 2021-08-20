require "mini_program/version"
require "mini_program/engine"
require "mini_program/client"
require "mini_program/msg"
require "mini_program/user"
require "application_controller_ext"
require "r_logger"
require "service_result"
require "redis"
require "mocha"

module MiniProgram
  mattr_accessor :appid, :app_secret

  def self.setup
    yield self if block_given?
  end

end
