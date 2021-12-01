require 'chunky_png'
require 'colorize'
require 'core/test'

module Tony
  module Test
    module Goldens
      class Page
        include ::Capybara::RSpecMatchers
        include ::ChunkyPNG::Color
        include ::RSpec::Matchers
        include ::Test::Env

        def initialize(page, goldens_folder = 'spec/goldens')
          @page = page
          @goldens_folder = goldens_folder
        end

        def verify(filename)
          return if ENV.fetch('CHROME_DEBUG', false)

          expect(@page).to(have_googlefonts)

          Dir.mkdir(tmp_dir) unless File.exist?(tmp_dir)
          @page.driver.save_screenshot(tmp_file(filename), { full: true })

          unless File.exist?(golden_file(filename))
            warn("Golden not found for: #{filename}".red)
            Goldens.mark_failure(Failure.new(name: filename,
                                             golden: golden_file(filename),
                                             new: tmp_file(filename)))
            return
          end

          golden_bytes = File.read(golden_file(filename), mode: 'rb')
          new_bytes = File.read(tmp_file(filename), mode: 'rb')
          return if golden_bytes == new_bytes

          if ENV.key?('GOLDENS_PIXEL_TOLERANCE')
            difference = pixel_diff(golden_file(filename), tmp_file(filename))
            warn("Pixel difference of #{difference}% for #{filename}".yellow)
            return if difference < ENV.fetch('GOLDENS_PIXEL_TOLERANCE').to_f
          end

          warn("Golden match failed for: #{filename}".red)
          Goldens.mark_failure(Failure.new(name: filename,
                                           golden: golden_file(filename),
                                           new: tmp_file(filename)))
          return unless ENV.fetch('FAIL_ON_GOLDEN', false) || github_actions?

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
          return Dir.tmpdir unless github_actions?

          File.join(@goldens_folder, 'failures')
        end

        def pixel_diff(file_before, file_after)
          img_one = ChunkyPNG::Image.from_file(file_before)
          img_two = ChunkyPNG::Image.from_file(file_after)
          return 100 if img_one.dimension != img_two.dimension

          return ((img_one.pixels.zip(img_two.pixels).sum { |px_one, px_two|
            Math.sqrt(
                ((r(px_two) - r(px_one))**2) +
                ((g(px_two) - g(px_one))**2) +
                ((b(px_two) - b(px_one))**2)) / Math.sqrt((MAX**2) * 3)
          } / img_one.area) * 100).round(2)
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
