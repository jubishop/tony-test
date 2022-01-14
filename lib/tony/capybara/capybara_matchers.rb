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
