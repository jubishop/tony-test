require 'capybara/rspec'
require 'rack/test'
require 'rspec'

RSpec.shared_context(:tony_capybara) {
  include Capybara::RSpecMatchers
  include Tony::Test::Capybara::Cookies

  before(:each) {
    page.driver.headers = { Origin: 'http://localhost' }
  }

  after(:each) {
    clear_cookies
    Capybara.reset_sessions!
  }
}

RSpec.shared_context(:tony_rack_test) {
  include Capybara::RSpecMatchers
  include Rack::Test::Methods
  include Tony::Test::Rack::Cookies
  include Tony::Test::Rack::Slim

  after(:each) {
    clear_cookies
  }
}
