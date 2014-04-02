require 'json'
require 'webrick'


class Flash

  def initialize(req)
    req.cookies.each do |cookie|
      if cookie.name == '_rails_lite_app_flash'
        @values = JSON.parse(cookie.value)
      end
    end
    @values ||= {:to_delete => false}
  end

  def destroy_now?
    !@delete_on_render.nil?
  end

  def destroy?
    self[:to_delete]
  end

  def now
    @delete_on_render = true
    self
  end

  def [](key)
    @values[key]
  end

  def []=(key, value)
    @values[key] = value
  end

  def store_flash(res)
    self[:to_delete] = true
    cookie = WEBrick::Cookie.new('_rails_lite_app_flash', @value.to_json)
    res.cookies << cookie
  end

end