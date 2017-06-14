# coding: utf-8
require_relative 'lib/heroku_lockdown/version'

Gem::Specification.new do |spec|
  spec.name          = 'heroku_lockdown'
  spec.version       = HerokuLockdown::VERSION
  spec.authors       = ['George Shaw']
  spec.email         = ['gshaw@westfield.com']

  spec.summary       = %q{Rack middleware to refuse access if X-API-SECRET header does not contain required value.}
  spec.description   = %q{Refuse access if X-API-SECRET header does not contain required value. Allow unrestricted access to selected paths.}
  spec.homepage      = 'https://www.github.com/westfieldlabs/heroku_lockdown'
  spec.license       = 'Apache-2.0'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.2.2'

  spec.add_dependency 'rack'

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rack-test'
  spec.add_development_dependency 'json'
end
