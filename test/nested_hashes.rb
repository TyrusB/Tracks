def parse_www_encoded_form(www_encoded_form)
  #1 simple cases:
  {}.tap do |params|
    www_encoded_form.each do |attribute_string, value|
      nested_keys = parse_key(attribute_string)

      value_hash = { nested_keys.pop => value }

      unless nested_keys.empty?
        new_hash = nested_keys.reverse.inject(value_hash) do |accum, key|
          result = { key => accum }
        end
      end

      p new_hash

      #params.merge(new_hash)
    end
  end
end

def parse_key(key)
  key.split(/\]\[|\[|\]/)
end

def method2(www_encoded_form)
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



