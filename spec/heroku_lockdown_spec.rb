require 'json'

RSpec.describe HerokuLockdown do
  it 'has a version number' do
    expect(HerokuLockdown::VERSION).not_to be nil
  end

  describe HerokuLockdown::SecureAccess, type: :request do
    REPORTED_VERSION = 'test_version'
    REQUEST_HEADER = 'HTTP_X_WF.API_SECRET'

    def app
      Rack::Builder.new do
      # Global variables are needed to keep the values in scope
      use HerokuLockdown::SecureAccess, $x_api_secret, REPORTED_VERSION, $allowed_regx_paths
        run lambda {|env| [200, {}, ['Hello World']]}
      end.to_app
    end

    before do
      # Default middleware initialization values
      $x_api_secret = '12345'
      $allowed_regx_paths = []
    end

    response = nil
    let(:json) { JSON.parse(response.body) }
    let(:errors) { json['errors'] }

    it 'allows access when no middleware key is set' do
      $x_api_secret = nil

      response = get '/', {}, {}
      expect(response.status).to eq 200
      expect(response.body).to eq 'Hello World'
    end

    it 'returns 401 missing header when accessed with no key' do
      expected_error =
        {
          'x-wf.api-secret' => [ 'header is missing']
        }

      response = get '/', {}, {}
      expect(response.status).to eq 401
      expect(errors).to eq expected_error
    end

    it 'returns the expected meta and version on error' do
      expected_meta =
        {
          'api_version' => REPORTED_VERSION,
          'deprecation_information' => { },
        }

      response = get '/', {}, {}
      expect(json['meta']).to eq expected_meta
    end

    it 'allows access with a valid key' do
      $x_api_secret = '12345'
      env = { REQUEST_HEADER => $x_api_secret }

      response = get '/', {}, env
      expect(response.status).to eq 200
      expect(response.body).to eq 'Hello World'
    end

    it 'returns 401 invalid header when accessed with an incorrect key' do
      expected_error =
        {
          'x-wf.api-secret' => [ 'header is invalid']
        }
      env = { REQUEST_HEADER => 'Wrong_Key' }

      response = get '/', {}, env
      expect(response.status).to eq 401
      expect(errors).to eq expected_error
    end

    it 'allows access to status.json path with no key' do
      response = get '/status.json', {}, {}
      expect(response.status).to eq 200
      expect(response.body).to eq 'Hello World'
    end

    it 'allows access to status_all.json path with no key' do
      response = get '/status_all.json', {}, {}
      expect(response.status).to eq 200
      expect(response.body).to eq 'Hello World'
    end

    it 'allows access to additional paths with no key' do
      $allowed_regx_paths = [/\/test/]

      response = get '/test', {}, {}
      expect(response.status).to eq 200
      expect(response.body).to eq 'Hello World'
    end
  end
end
