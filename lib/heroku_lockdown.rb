# Rack Middleware to secure access via a required header token

module HerokuLockdown

  class SecureAccess
    DEFAULT_ALLOWED_PATHS = [
      # Allow status checker
      %r{\A/status.json\z}i,
      %r{\A/status_all.json\z}i
    ].freeze

    def initialize app, x_api_secret, version = "1.4", service_allowed_paths = []
      @app = app
      @x_api_secret = x_api_secret
      @version = version
      @allowed_paths = (DEFAULT_ALLOWED_PATHS + service_allowed_paths).freeze
    end

    def return_401 message
      {
        data: { },
        errors: {
          "x-wf.api-secret": [ message ],
        },
        meta: {
          api_version: @version,
          deprecation_information: { },
        }
      }.to_json
    end

    def authorized? env
      @x_api_secret ? (env['HTTP_X_WF.API_SECRET'] == @x_api_secret) : true
    end

    def auth_key_present? env
      env.has_key?('HTTP_X_WF.API_SECRET')
    end

    def call env
      return @app.call(env) if authorized? env

      # Make these check separately to optimize the common path.
      # Defaults allow health check to not require a key.
      request = Rack::Request.new(env)

      @allowed_paths.each do |path|
        return @app.call(env) if request.path =~ path
      end

      suffix = auth_key_present?(env) ? 'invalid' : 'missing'
      body = return_401("header is #{suffix}")

      headers =
        {
          'Content-Type' => 'application/json',
        }
      [401, headers, [body]]
    end

  end
end
