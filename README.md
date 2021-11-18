# MiniProgram
Short description and motivation.

## 开始

1. 添加`gem` 
```ruby
gem 'mini_program'
```

2. 执行 bundle 
```bash
$ bundle
```

3. 生成`initializer`文件，需要將里边的内容修改成你自己的小程序的配置
```bash
$ rails g mini_program:install
```

4. 如果需要订阅消息，使用如下命令生成订阅消息的配置
```bash
$ rails g mini_program:msg_config
```

## 使用

#### 授权登录(获取openid)
```ruby
mp = MiniProgram::Client.new

# code 是在小程序端调用 wx.login 拿到的
result = mp.login(code)
if result.success?
  openid = result.data[:openid]
  session_key = result.data[:session_key]
end
```

#### 获取手机号
```ruby
mp = MiniProgram::Client.new 

# 小程序端 wx.login 拿到的 code
code = "041PuvGa1rysrB0noDJa1n7RBv2PuvGe"

# encrypted_data 和 iv 都是小程序端 getPhoneNum 获取到的参数
encrypted_data = "3G/+Fh6kCBaQszXFTxz3h3HFSbu0UuVW/4aLbz8WGzrKfmbGpvnxYHAa4QrKXJvHpB++3ogOYoU6iiG+1HW18Lkt9qEJE9GyRw5OnuXSjTnUIPSRROT3sxeAYnT1kf4ngTAfrD3f4TFtLXkRIrrc1MzSqx/LV8iXA8Lu5Y+7kZx26eulz3yVrlXDH3BOIX6zcGOeprsK5XzDx2ltmf3j5w=="
iv = "5tiyfVEHNVgHN4n8lzDrUA=="

result = mp.get_phone_num(code: code, encrypted_data: encrypted_data, iv: iv)

if result.success?
  phone_num = result.data[:phone] 
  
  # 或者直接使用 [] 方法获取
  # phone_num = result[:phone_num]
end

```

#### 发送订阅消息
```ruby

# 订阅消息配置 ，具体模板配置请参考小程序后台模板配置
# 
# config/subscribe_msg.yml
# 
# progress:
#   template_id: YQ0cmL_ugsXwPaA2Pl75IMo_qtoc1n6CtT1orIeX4_o
#   page: "/pages/index/index"
#   data:
#     thing2:
#       value: "%{title}"
#     phrase4:
#       value: "%{state}"
#     thing1:
#       value: "%{detail}"

msg = MiniProgram::Msg.new(:progress, {
  title: "测试",
  state: "已完成",
  detail: "测试已完成"
})

# send_to 的参数可以是 openid(字符串)，或者是带有 openid 方法的对象，返回 MiniProgram::ServiceResult
result = msg.send_to("ogT7J5YddGnll-ippRvJq62Nv5W0")

# or
user = User.first
user.openid # => ogT7J5YddGnll-ippRvJq62Nv5W0
result = msg.send_to(user)

if result.success?
  puts "发送成功"
end

```

#### 获取`access-token`
```ruby
mp = MiniProgram::Client.new

# 缓存在 redis 中，缓存时间为 1.5 小时，微信官方`access-token`过期时间是 2小时
result = mp.get_access_token
if result.success?
  access_token = result[:access_token]
end

# 传入 fresh: true 可以不使用缓存，直接调用微信api获取到 token，默认为 false
result = mp.access_token fresh:true
```

#### MiniProgram::ServiceResult 类
```ruby
# success 默认为 false
result = MiniProgram::ServiceResult.new(success: true, data: {data1: 1})

## 处理结果(成功)
if result.success?
  # do something...
end

# or
result.on_success do |result|
  # do something...
end

## 处理结果(失败)
if result.failure?
  # do something...
end

result.on_failure do |result|
  # do something...
end



```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
