require 'colorize'
require 'core/test'

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
          return if ENV.fetch('CHROME_DEBUG', false)

          puts Dir.tmpdir

          expect(@page).to(have_googlefonts)

          @page.driver.save_screenshot(tmp_file(filename), { full: true })

          unless File.exist?(golden_file(filename))
            warn("Golden not found for for: #{filename}".red)
            Goldens.mark_failure(Failure.new(name: filename,
                                             golden: golden_file(filename),
                                             new: tmp_file(filename)))
            return
          end

          golden_bytes = File.read(golden_file(filename), mode: 'rb')
          new_bytes = File.read(tmp_file(filename), mode: 'rb')
          return if golden_bytes == new_bytes

          warn("Golden match failed for: #{filename}".red)
          Goldens.mark_failure(Failure.new(name: filename,
                                           golden: golden_file(filename),
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
          return File.join(tmp_dir, "#{filename}.png")
        end

        def tmp_dir
          return github_actions? ? 'spec/goldens/failures' : Dir.tmpdir
        end

        class Failure
          attr_accessor :name, :golden, :new

          def initialize(name:, golden:, new:)
            @name = name
            @golden = File.expand_path(golden)
            @new = File.expand_path(new)
          end
        end
      end
    end
  end
end
