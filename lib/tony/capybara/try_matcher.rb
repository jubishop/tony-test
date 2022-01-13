module TryMatcher
  def try(wait: Capybara.default_max_wait_time)
    (wait * 10).times {
      return true if yield

      sleep(0.1)
    }
    return false
  end
end
