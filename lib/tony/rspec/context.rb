require 'capybara/rspec'
require 'rack/test'
require 'rspec'

RSpec.shared_context(:tony_rack_test) {
  include Capybara::RSpecMatchers
  include Rack::Test::Methods
  include Tony::Test::Rack::Cookies

  after(:each) {
    clear_cookies
  }
}
