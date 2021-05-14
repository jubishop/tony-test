require 'rspec'

module Tony
  module Test
    module Goldens
      @failures = []
      def self.mark_failure(failure)
        @failures.push(failure)
      end

      def self.review_failures
        Server.new(@failures)
      end
    end
  end
end

RSpec.configure { |config|
  config.after(:suite) {
    Tony::Test::Goldens.review_failures
  }
}
