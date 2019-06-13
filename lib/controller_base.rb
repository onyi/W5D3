require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'
require 'active_support/inflector'

class ControllerBase
  attr_reader :req, :res, :params, :session

  # Setup the controller
  def initialize(req, res)
    @res = res
    @req = req
    @session ||= Session.new(@req)
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    raise "Already built" if already_built_response?
    @res.status = 302
    @res.location = url
    @already_built_response = true
    @session.store_session(@res)

  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    raise "Already built" if already_built_response?
    @res['Content-Type'] = content_type
    # @res.body = content
    @res.write(content)
    @already_built_response = true
    @session.store_session(@res)
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    raise "Already built" if already_built_response?
    view_dir = File.dirname(__FILE__) # Get current directory path
    # p "Directory: #{view_dir}"
    view_file = File.join(view_dir, "../", "views/#{self.class.name.underscore}", "#{template_name}.html.erb")
    # p "View File Path: #{view_file}"
    erb_content = ERB.new(File.read(view_file)).result(binding)
    render_content(erb_content ,"text/html")
  end

  # method exposing a `Session` object
  def session
    @session
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
  end
end

