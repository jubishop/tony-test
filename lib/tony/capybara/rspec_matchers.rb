require 'rspec/expectations'

module RSpec
  module Matchers
    def try(wait: Capybara.default_max_wait_time)
      start_time = ::Time.now
      # rubocop:disable Style/WhileUntilModifier
      while ::Time.now - start_time < wait
        return true if yield
      end
      # rubocop:enable Style/WhileUntilModifier
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
