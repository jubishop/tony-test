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
            difference = pixel_diff(tmp_file(filename), golden_file(filename))
            warn("Pixel difference of #{difference}% for #{filename}")
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

        def pixel_diff(file_one, file_two)
          diff_total = 0

          image_one = ChunkyPNG::Image.from_file(file_one)
          image_two = ChunkyPNG::Image.from_file(file_two)
          image_one.height.times { |y|
            image_one.width.times { |x|
              pixel_one = image_one.get_pixel(x, y)
              pixel_two = image_two.get_pixel(x, y)
              next if pixel_one == pixel_two

              diff_total += Math.sqrt(
                  ((r(pixel_two) - r(pixel_one))**2) +
                  ((g(pixel_two) - g(pixel_one))**2) +
                  ((b(pixel_two) - b(pixel_one))**2)) / Math.sqrt((MAX**2) * 3)
            }
          }

          return (diff_total / image_one.pixels.length) * 100
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
