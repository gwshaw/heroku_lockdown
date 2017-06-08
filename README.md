# HerokuLockdown

Rack middleware to add to a micro service to prevent access to the Heroku servers without a key.

- a valid key must be supplied in the `x-api-secret` header.
- exceptions are allowed for:
  - /status.json and
  - /status_all.json
- additional exceptions can be defined at initialization.
- errors are currently returned in Westfield V1 format. Other versions will be supplied in a later revision.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'heroku_lockdown'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install heroku_lockdown

## Usage

In config/application.rb configuration block, add

```ruby
module SomeService
  REPORTING_VERSION = '1.4'
  class Application < Rails::Application

    config.middleware.insert_before(Rack::Runtime, 'HerokuLockdown::SecureAccess', ENV['X_API_SECRET'], REPORTING_VERSION, [ additional_path_regexs ])

  end
end
```
This places the middlware at the beginning of the list of Rails middleware. It is desirable to have this as early as possible. With the development of Rails, this location may need to change.

The key that the service expects is stored in the environment variable `X_API_SECRET`. Each service should have its own unique key.

`additional_path_regexes` are regular expressions for any other paths (no host) that should be allowed without supplying the required key. For security it is best if they are complete and anchored at both ends, e.g. `/\A/v\d\/swagger\z/i`

In normal operation, the gateway routers insert the `x-api-secret` header and the appropriate key so operation is invisible. The effect is to require access to go through the gateway public endpoints and to not directly communicate with the Heroku servers.

If the `X_API_SECRET` environment variable is not defined in the service, then the key is not required. This allows local development without keys, and disabling the lock down when needed.
