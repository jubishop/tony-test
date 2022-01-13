require 'capybara'
require 'capybara/rspec'

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

Capybara::RSpecMatchers.include(Tony::Test::Capybara::Matchers)

require_relative 'try_matcher'

RSpec::Matchers.define(:have_focus) { |wait: Capybara.default_max_wait_time|
  include TryMatcher
  match { |actual|
    try(wait: wait) {
      actual.evaluate_script('document.activeElement') == actual
    }
  }
}

RSpec::Matchers.define(:be_disabled) { |wait: Capybara.default_max_wait_time|
  include TryMatcher
  match { |actual|
    try(wait: wait) {
      actual[:disabled]
    }
  }
}
