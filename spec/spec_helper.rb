ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'webmock/rspec'

OmniAuth.config.test_mode = true

RSpec.configure do |config|
  config.before :suite do
    DatabaseRewinder.clean_all
  end

  config.after do
    DatabaseRewinder.clean
  end

  VCR.configure do |c|
    c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
    c.hook_into :webmock
  end

  config.include FactoryBot::Syntax::Methods
end

def sign_in_as(user)
  credentials = OmniAuth::AuthHash.new
  credentials.token = 'xxxxxxxxxxxxxxx'

  auth_hash = OmniAuth::AuthHash.new
  auth_hash.uid = user.account_id
  auth_hash.credentials = credentials

  OmniAuth.config.mock_auth[:colormeshop] = auth_hash

  VCR.use_cassette('requests/sessions/script_tags') do
    get '/auth/colormeshop/callback', params: { provider: 'colormeshop' }
  end
end
