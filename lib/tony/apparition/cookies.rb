require 'tony'

module Tony
  module Test
    module Apparition
      module Cookies
        def set_cookie(name, value)
          crypt = Tony::Utils::Crypt.new(cookie_secret)
          page.driver.set_cookie(name, crypt.en(value))
        end

        def get_cookie(name)
          crypt = Tony::Utils::Crypt.new(cookie_secret)
          return crypt.de(page.driver.cookies[name.to_s].value)
        end

        def delete_cookie(name)
          page.driver.remove_cookie(name)
        end

        def clear_cookies
          page.driver.clear_cookies
        end
      end
    end
  end
end
