require 'erb'
require 'aspector'
require_relative '../models/player_session.rb'
require_relative '../models/player_storage.rb'

class BaseController

  aspector do
    target do 
      def redirect_if_guest(proxy, *args, &block)
        return redirect_default if !@request.session[:player]

        proxy.call *args, &block
      end
    end
  end

  attr_reader :request

  def initialize(request)
    @request = request
  end
  
  def index
    if @request.session[:player]
      return redirect_to('/game/new')
    end

    if !@request.session[:player] && params['name'] && params['name'] != ''
      @request.session[:player] = PlayerSession.new(params['name'])

      return redirect_to('/game/new')
    end

    build_response render_template
  end

  def logout
    destroy_session

    return redirect_default
  end

  private

  def is_admin
    @request.session[:player].name == 'superadmin'
  end

  def destroy_session
    @request.session.destroy
  end

  def build_response(body, status: 200)
    [status, { "Content-Type" => "text/html" }, [body]]
  end

  def redirect_to(uri)
    [302, { "Location" => uri }, []]
  end

  def redirect_default
    redirect_to('/base/index')
  end

  def params
    request.params
  end

  def render_partial(template_file)
    file_path = template_file_path_for(template_file)

    if File.exists?(file_path)
      puts " > Rendering partial file #{template_file}"
      render_erb_file(file_path)
    else
      "ERROR: no available partial file #{template_file}"
    end
  end

  def render_template(name = params[:action])
    templates_dir = self.class.name.downcase.sub("controller", "")
    template_file = File.join(templates_dir, "#{name}.html.erb")

    file_path = template_file_path_for(template_file)

    if File.exists?(file_path)
      puts "Rendering template file #{template_file}"
      render_erb_file(file_path)
    else
      "ERROR: no available template file #{template_file}"
    end
  end

  def template_file_path_for(file_name)
    File.expand_path(File.join("../../views", file_name), __FILE__)
  end

  def render_erb_file(file_path)
    raw = File.read(file_path)
    ERB.new(raw).result(binding)
  end

end