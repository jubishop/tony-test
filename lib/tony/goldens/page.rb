require 'chunky_png'
require 'colorize'
require 'core/test'
require 'fileutils'

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

        def verify(filename, expect_fontawesome: true)
          return if ENV.fetch('CHROME_DEBUG', false)

          expect(@page).to(have_fontawesome) if expect_fontawesome

          FileUtils.mkdir_p(tmp_dir)
          @page.driver.save_screenshot(tmp_file(filename), full: true)

          unless File.exist?(golden_file(filename))
            warn("Golden not found for: #{file_id(filename)}".red)
            Goldens.mark_failure(Failure.new(name: file_id(filename),
                                             golden: golden_file(filename),
                                             new: tmp_file(filename)))
            return
          end

          golden_bytes = File.read(golden_file(filename), mode: 'rb')
          new_bytes = File.read(tmp_file(filename), mode: 'rb')
          return if golden_bytes == new_bytes

          golden_img = ChunkyPNG::Image.from_file(golden_file(filename))
          tmp_img = ChunkyPNG::Image.from_file(tmp_file(filename))

          if ENV.key?('GOLDENS_PIXEL_TOLERANCE')
            tolerance = ENV.fetch('GOLDENS_PIXEL_TOLERANCE').to_f
            diff_percent = (total_pixel_difference(
                golden_img, tmp_img) * 100).round(2)
            warn("Pixel difference of #{diff_percent}% for #{filename}".yellow)
            return if diff_percent < tolerance

            warn("  - Exceeds tolerance of #{tolerance}%".red)
          end

          FileUtils.mkdir_p(diff_dir)
          difference_image(golden_img, tmp_img).save(diff_file(filename))

          warn("Golden match failed for: #{file_id(filename)}".red)
          puts("Page body is: #{@page.body}")
          Goldens.mark_failure(Failure.new(name: file_id(filename),
                                           golden: golden_file(filename),
                                           new: tmp_file(filename),
                                           diff: diff_file(filename)))
          return unless ENV.fetch('FAIL_ON_GOLDEN', false) || github_actions?

          raise ::RSpec::Expectations::ExpectationNotMetError,
                "#{filename} does not match"
        end

        private

        def file_id(filename)
          return File.join(@goldens_folder, filename)
        end

        def golden_file(filename)
          return File.join(@goldens_folder, "#{filename}.png")
        end

        def tmp_file(filename)
          return File.join(tmp_dir, "#{filename}.png")
        end

        def diff_file(filename)
          return File.join(diff_dir, "#{filename}.png")
        end

        def tmp_dir
          return File.join(Dir.tmpdir, @goldens_folder)
        end

        def diff_dir
          return File.join(tmp_dir, 'diffs')
        end

        def total_pixel_difference(img_one, img_two)
          return 100 if img_one.dimension != img_two.dimension

          return img_one.pixels.zip(img_two.pixels).sum { |px_one, px_two|
            single_pixel_difference(px_one, px_two)
          } / img_one.area
        end

        def single_pixel_difference(px_one, px_two)
          return 0 if px_one == px_two
          return 1.0 unless px_one && px_two

          return Math.sqrt(
              ((r(px_two) - r(px_one))**2) +
              ((g(px_two) - g(px_one))**2) +
              ((b(px_two) - b(px_one))**2)) / Math.sqrt((MAX**2) * 3)
        end

        def difference_image(img_one, img_two)
          max_width = [img_one.width, img_two.width].max
          max_height = [img_one.height, img_two.height].max
          new_img = ChunkyPNG::Image.new(max_width, max_height, WHITE)

          0.upto(max_height - 1) { |y|
            0.upto(max_width - 1) { |x|
              if img_one.include_xy?(x, y) && img_two.include_xy?(x, y)
                score = single_pixel_difference(img_one[x, y], img_two[x, y])
                new_img[x, y] = grayscale(MAX - (score * 255).round)
              else
                new_img[x, y] = html_color(:red)
              end
            }
          }

          return new_img
        end

        class Failure
          attr_accessor :name, :golden, :new, :diff

          def initialize(name:, golden:, new:, diff: nil)
            @name = name
            @golden = File.expand_path(golden)
            @new = File.expand_path(new)
            @diff = File.expand_path(diff) if diff
          end
        end
      end
    end
  end
end
