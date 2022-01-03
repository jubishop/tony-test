require 'tony'

module Tony
  module Test
    module RSpec
      module Slim
        def expect_slim(template, views: nil, layout: nil, **attributes)
          original_render = Tony::Slim.instance_method(:render)
          expect_any_instance_of(Tony::Slim).to(receive(:render)).with(
              template, **attributes).exactly(1).time { |slim, *args|
                expect(slim.views).to(eq(views)) if views
                expect(slim.layout.file.chomp('.slim')).to(eq(layout)) if layout
                original_render.bind_call(slim, *args)
              }
        end
      end
    end
  end
end
