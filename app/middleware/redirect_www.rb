class RedirectWww
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)

    if request.host.start_with?('www.')
      [301, {'Location' => request.url.sub('//www.', '//'), 'Content-Type' => 'text/html'}, []]
    else
      @app.call(env)
    end
  end
end
