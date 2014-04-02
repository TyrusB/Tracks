require 'uri'

class Params
  # use your initialize to merge params from
  # 1. query string
  # 2. post body
  # 3. route params
  def initialize(req, route_params = {})
    @params = {}

    unless req.query_string.nil?
      unencoded = URI.decode_www_form(req.query_string)
      @params = parse_www_encoded_form(unencoded)
    end
    unless req.body.nil?
      post_params = URI.decode_www_form(req.body)
      @params.merge!(parse_www_encoded_form(post_params))
    end

    @params.merge!(route_params)

    @params

  end

  def [](key)
    @params[key]
  end

  def permit(*keys)
  end

  def require(key)
  end

  def permitted?(key)
  end

  def to_s
    @params.to_s
  end

  class AttributeNotFoundError < ArgumentError; end;

  private
  # this should return deeply nested hash
  # argument format
  # user[address][street]=main&user[address][zip]=89436
  # should return
  # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
  def parse_www_encoded_form(www_encoded_form)
    params = {}

    www_encoded_form.each do |attribute_string, value|
      nested_keys = parse_key(attribute_string)
      last_key = nested_keys.pop

      last = params

      nested_keys.each do |key|
        if last[key].nil?
          last[key] = {}
        end
        last = last[key]
      end

      last[last_key] = value

    end

    params
  end

  # this should return an array
  # user[address][street] should return ['user', 'address', 'street']
  def parse_key(key)
    key.split(/\]\[|\[|\]/)
  end
end












