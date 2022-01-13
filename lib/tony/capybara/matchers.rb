require 'capybara/rspec'
require 'capybara'

module Tony
  module Test
    module Capybara
      module Matchers
        # rubocop:disable Naming/PredicateName
        def have_fontawesome
          have_selector('.fontawesome-i2svg-complete')
        end

        def have_timezone
          have_selector('.timezone-loaded')
        end
        # rubocop:enable Naming/PredicateName
      end
    end
  end
end

module TryMatcher
  def try(wait: Capybara.default_max_wait_time)
    (wait * 10).times {
      return true if yield

      sleep(0.1)
    }
    return false
  end
end

RSpec::Matchers.define(:have_focus) { |wait: Capybara.default_max_wait_time|
  include TryMatcher
  match { |actual|
    try(wait: wait) {
      actual.evaluate_script('document.activeElement') == actual
    }
  }
}

Capybara::RSpecMatchers.include(Tony::Test::Capybara::Matchers)
