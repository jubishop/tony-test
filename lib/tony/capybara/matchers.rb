require 'capybara/rspec'

module Tony
  module Test
    module Capybara
      module Matchers
        # rubocop:disable Naming/PredicateName
        def have_fontawesome
          have_selector(:css, '.fontawesome-i2svg-complete')
        end
        # rubocop:enable Naming/PredicateName
      end
    end
  end
end

Capybara::RSpecMatchers.include(Tony::Test::Capybara::Matchers)
