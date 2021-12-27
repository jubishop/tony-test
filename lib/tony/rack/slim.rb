require 'tony'

module Tony
  module Test
    module Rack
      module Slim
        def expect_slim(template, views: nil, layout: nil, **attributes)
          expect_any_instance_of(Tony::Slim).to(receive(:render)).with(
              template, **attributes).exactly(1).time { |slim|
                expect(slim.views).to(eq(views)) if views
                expect(slim.layout.file.chomp('.slim')).to(eq(layout)) if layout
              }
        end
      end
    end
  end
end
