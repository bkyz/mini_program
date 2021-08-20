Rails.application.routes.draw do
  get 'demo/index'
  mount MiniProgram::Engine => "/mini_program"
end
