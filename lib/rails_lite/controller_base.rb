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

  def render_content(content, type)
    @res.body = content
    @res.content_type = type

    raise "Already rendered" if already_rendered?
    @already_built_response = true

    self.session.store_session(@res)
    self.flash.store_flash unless self.flash.destroy_now?
  end

  def already_rendered?
    !!@already_built_response
  end

  def redirect_to(url)
    @res.status = 302
    @res["location"] = url

    raise "Already rendered" if already_rendered?
    @already_built_response = true

    self.session.store_session(@res)
    self.flash.store_flash unless self.flash.destroy?
  end

  # ERB implementation using binding
  def render(template_name)
    data = File.read("views/#{self.class.to_s.underscore}/#{template_name.to_s}.html.erb")
    erb = ERB.new(data).result(binding)

    render_content(erb, 'text/html')
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  # calls action name for router
  def invoke_action(name)
    self.send(name)
    render(name) unless already_rendered?
  end

  def flash
    @flash ||= Flash.new(@req)
  end


  end
end
