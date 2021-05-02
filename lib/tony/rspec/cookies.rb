module Tony
  module Test
    module RSpec
      module Cookies
        def set_cookie(name, value)
          crypt = Tony::Utils::Crypt.new(cookie_secret)
          rack_mock_session.cookie_jar[name] = crypt.en(value)
        end

        def get_cookie(name)
          crypt = Tony::Utils::Crypt.new(cookie_secret)
          return crypt.de(rack_mock_session.cookie_jar[name])
        end

        def delete_cookie(name)
          rack_mock_session.cookie_jar.delete(name)
        end
      end
    end
  end
end
