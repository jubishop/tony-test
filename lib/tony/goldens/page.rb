require 'core/test'
require 'colorize'

module Tony
  module Test
    module Goldens
      class Page
        include ::Capybara::RSpecMatchers
        include ::RSpec::Matchers
        include ::Test::Env

        def initialize(page, goldens_folder = 'spec/goldens')
          @page = page
          @goldens_folder = goldens_folder
        end

        def verify(filename)
          return if github_actions?

          expect(@page).to(have_googlefonts)

          @page.driver.save_screenshot(tmp_file(filename), { full: true })

          unless File.exist?(golden_file(filename))
            Goldens.mark_failure(Failure.new(golden: golden_file(filename),
                                             new: tmp_file(filename)))
            return
          end

          golden_bytes = File.read(golden_file(filename), mode: 'rb')
          new_bytes = File.read(tmp_file(filename), mode: 'rb')
          return if golden_bytes == new_bytes

          warn("Golden match failed for: #{filename}".red)
          Goldens.mark_failure(Failure.new(golden: golden_file(filename),
                                           new: tmp_file(filename)))
          return unless ENV.fetch('FAIL_ON_GOLDEN', false)

          raise ::RSpec::Expectations::ExpectationNotMetError,
                "#{filename} does not match"
        end

        private

        def golden_file(filename)
          return File.join(@goldens_folder, "#{filename}.png")
        end

        def tmp_file(filename)
          return File.join(Dir.tmpdir, "#{filename}.png")
        end

        class Failure
          attr_accessor :golden, :new

          def initialize(golden:, new:)
            @golden = File.expand_path(golden)
            @new = File.expand_path(new)
          end
        end
      end
    end
  end
end
