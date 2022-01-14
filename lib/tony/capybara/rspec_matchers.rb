require 'rspec/expectations'

module RSpec
  module Matchers
    def try(wait: Capybara.default_max_wait_time)
      (wait * 10).times {
        return true if yield

        sleep(0.1)
      }
      return false
    end
  end
end

RSpec::Matchers.define(:have_focus) { |wait: Capybara.default_max_wait_time|
  match { |actual|
    try(wait: wait) {
      actual.evaluate_script('document.activeElement') == actual
    }
  }
  match_when_negated { |actual|
    try(wait: wait) {
      actual.evaluate_script('document.activeElement') != actual
    }
  }
}

RSpec::Matchers.define(:be_disabled) { |wait: Capybara.default_max_wait_time|
  match { |actual|
    try(wait: wait) {
      actual[:disabled]
    }
  }
  match_when_negated { |actual|
    try(wait: wait) {
      !actual[:disabled]
    }
  }
}

RSpec::Matchers.define(:be_visible) { |wait: Capybara.default_max_wait_time|
  match { |actual|
    try(wait: wait) {
      actual.visible?
    }
  }
  match_when_negated { |actual|
    try(wait: wait) {
      !actual.visible?
    }
  }
}

RSpec::Matchers.define(:be_gone) { |wait: Capybara.default_max_wait_time|
  match { |actual|
    try(wait: wait) {
      begin
        actual.visible?
      rescue StandardError => error
        error.class.name.include?('ObsoleteNode')
      else
        false
      end
    }
  }
}
