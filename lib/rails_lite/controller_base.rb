require 'erb'
require 'active_support/inflector'
require_relative 'params'
require_relative 'session'
require_relative 'url_helper'

class ControllerBase

  SECRET_TOKEN = "ThisIsTheSecretToken"

  attr_reader :params, :req, :res

  # setup the controller
  def initialize(req, res, route_params = {})
    @req, @res = req, res
    @params = Params.new(@req, route_params)

    UrlHelper::build_route_helpers(self.class.to_s)

    verify_CSRF
  end

  def verify_CSRF
    if ["POST", "PATCH", "PUT"].include?(@req.request_method.to_s.upcase)
      raise "Invalid Authencity Token" unless @params[:authenticity_token] == SECRET_TOKEN
    end
  end

  # populate the response with content
  # set the responses content type to the given type
  # later raise an error if the developer tries to double render
  def render_content(content, type)
    @res.body = content
    @res.content_type = type

    raise "Already rendered" if already_rendered?
    @already_built_response = true

    self.session.store_session(@res)
    self.flash.store_flash unless self.flash.destroy_now?
  end

  # helper method to alias @already_rendered
  def already_rendered?
    !!@already_built_response
  end

  # set the response status code and header
  def redirect_to(url)
    @res.status = 302
    @res["location"] = url

    raise "Already rendered" if already_rendered?
    @already_built_response = true

    self.session.store_session(@res)
    self.flash.store_flash unless self.flash.destroy?
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    data = File.read("views/#{self.class.to_s.underscore}/#{template_name.to_s}.html.erb")
    erb = ERB.new(data).result(binding)

    render_content(erb, 'text/html')
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    self.send(name)
    render(name) unless already_rendered?
  end

  def flash
    @flash ||= Flash.new(@req)
  end


  end
end
