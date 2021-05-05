require 'capybara/rspec'
require 'rack-test'
require 'rspec'

RSpec.shared_context(:tony_rack_test) do
  include Capybara::RSpecMatchers
  include Rack::Test::Methods
  include Tony::Test::Rack::Cookies

  let(:cookie_secret) { 'fly_me_to_the_moon' }

  after(:each) {
    clear_cookies
  }
end
