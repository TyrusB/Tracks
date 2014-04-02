require 'debugger'
class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern, @http_method, @controller_class, @action_name =
        pattern, http_method, controller_class, action_name

  end

  # checks if pattern matches path and method matches request method
  def matches?(req)
    !(@pattern =~ req.path).nil? && req.request_method.downcase == @http_method.to_s.downcase
  end

  # use pattern to pull out route params
  # instantiate controller and call controller action
  def run(req, res)
    route_params = self.make_match_hash(req)
    controller = @controller_class.new(req, res, route_params)
    controller.invoke_action(@action_name)
  end

  def make_match_hash(req)
    match_data = self.pattern.match(req.path)
    {}.tap do |return_hash|
      match_data.names.each do |capture_name|
        return_hash[capture_name] = match_data[capture_name]
      end
    end
  end
end

class Router
  attr_reader :routes

  def initialize
    @routes = []
  end

  # simply adds a new route to the list of routes
  def add_route(pattern, method, controller_class, action_name)
    @routes << Route.new(pattern, method, controller_class, action_name)
  end

  # evalues proc in the context of the instance... syntactic sugar for our router.
  def draw(&proc)
    self.instance_eval(&proc)
  end

  [:get, :post, :put, :delete].each do |http_method|
    define_method(http_method) do |pattern, controller_class, action_name|
      @routes << Route.new(Regexp.new("#{pattern}"), http_method, controller_class, action_name)
    end
  end

  # should return the route that matches this request
  def match(req)
    @routes.each do |route|
      if route.matches?(req)
        return route
      end
    end

    nil
  end

  # either throw 404 or call run on a matched route
  def run(req, res)
    route_to_run = self.match(req)
    if route_to_run.nil?
      res.status = 404
    else
      route_to_run.run(req, res)
    end
  end
end
