[
  'rack',
  'rack/request',
  'rack/response',
  'rack/session/abstract/id'
].each { |file| require file }

app_files = File.expand_path('../app/**/*.rb', __FILE__)
Dir.glob(app_files).each { |file| require(file) }

class Application
  def call(env)
    serve_request(Rack::Request.new(env))
  end

  def serve_request(request)
    Router.new(request).route!
  end
end

use Rack::Session::Pool, cookie_only: false, defer: true

run Rack::Session::Pool.new(Application.new,
  expire_after: 2592000
)