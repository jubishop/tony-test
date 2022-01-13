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

module TryMatcher
  def try
    10.times {
      return true if yield

      sleep(0.1)
    }
    return false
  end
end

RSpec::Matchers.define(:have_focus) { |_|
  include TryMatcher
  match { |actual|
    try { actual.evaluate_script('document.activeElement') == actual }
  }
}

Capybara::RSpecMatchers.include(Tony::Test::Capybara::Matchers)
