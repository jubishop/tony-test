require 'core/test'
require 'fileutils'
require 'rspec'

module Tony
  module Test
    module Goldens
      @failures = []
      def self.mark_failure(failure)
        @failures.push(failure)
      end

      def self.review_failures
        return if @failures.empty?

        if ENV.fetch('FAIL_ON_GOLDEN', false) || ::Test::Env.github_actions?
          @failures.each { |failure|
            golden_folder = File.dirname(failure.golden)
            failures_folder = File.join(golden_folder, 'failures')
            FileUtils.mkdir_p(failures_folder)
            FileUtils.cp(failure.new, failures_folder)
            diffs_folder = File.join(golden_folder, 'diffs')
            FileUtils.mkdir_p(diffs_folder)
            FileUtils.cp(failure.diff, diffs_folder)
          }
        else
          Server.new(@failures)
        end
      end
    end
  end
end

RSpec.configure { |config|
  config.after(:suite) {
    Tony::Test::Goldens.review_failures
  }
}
