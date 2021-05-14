# tony-test

[![Rubocop Status](https://github.com/jubishop/tony-test/workflows/Rubocop/badge.svg)](https://github.com/jubishop/tony-test/actions/workflows/rubocop.yml)

Helpers for testing [Tony](https://github.com/jubishop/tony).

## Installation

### In a Gemfile

```ruby
source: 'https://www.jubigems.org/' do
  gem 'tony-test'
end
```

## RSpec

`tony-test` is designed for use with [`RSpec`](https://rspec.info) on top of either [`rack-test`](https://github.com/rack/rack-test) for basic http testing, or [`capybara-apparition`](https://github.com/twalpole/apparition) for testing inside a Chrome browser, with Javascript support and the ability to capture screenshots.

### Rack-Test

In your `spec_helper.rb`:

```ruby
require `tony-test`

RSpec.shared_context(:rack_test) {
  include_context(:tony_rack_test)

  let(:app) {
    # Create your tony app here.  Tony::App.new or whatever.
  }
  let(:cookie_secret) {
    # Return the same cookie secret string the app will be using.
  }
}
```

Now in any individual `_spec.rb` test file:

```ruby
# `type: :rack_test` will pull in the helpers for rack-test.
RSpec.describe(MyTonyApp, type: :rack_test) {
  it('does something') {
    # You can set cookies
    set_cookie(:key, 'value')

    # Standard stuff you do in rack-test
    get '/'

    # All standard Capybara matchers are available
    expect(last_response.body).to(have_selector('p.class'))
    expect(last_response.ok?).to(be(true))

    # You have two new matchers for content generated by `AssetTagHelper`:
    # have_fontawesome, and have_googlefonts
    expect(last_response.body).to(have_googlefonts)
  }
}
```

### Apparition

In your `spec_helper.rb`:

```ruby
require `tony-test`

# Of course you need to set Capybara.app here and call Capybara.register_driver
# and anything else to set up Capybara as per its documentation.

RSpec.shared_context(:apparition) do
  include_context(:tony_apparition)

  let(:cookie_secret) {
    # Return the same cookie secret string the app will be using.
  }
end
```

Now in any individual `_spec.rb` test file:

```ruby

# `type: :apparition` will pull in the helpers for apparition.
RSpec.describe(MyTonyApp, type: :apparition) {
  it('does something') {
    # You can set cookies
    set_cookie(:key, 'value')

    # Standard stuff you do in apparition
    visit('/')

    # All standard Capybara matchers are available
    expect(page).to(have_selector('p.class'))

    # You have two new matchers for content generated by `AssetTagHelper`:
    # have_fontawesome, and have_googlefonts
    expect(page).to(have_googlefonts)
  }
}
```

### Screenshot Goldens

`tony-test` offers a system for storing "golden" screenshots of your app which it can test for changes during a test run.  (Note, these will automatically skip execution when running inside Github Actions, since the screenshots will differ).  If they have changed, it then launches its own local `Tony` webserver and opens a browser where you can review those changes and choose whether to accept the new images as the new goldens.  If you accept, it copies the new image into your git repo, overwriting the original.

Example usage:

```ruby
RSpec.describe(Poll, type: :feature) {
  # Second param is the folder of your goldens, defaults to `spec/goldens`.
  let(:goldens) { Tony::Test::Goldens::Page.new(page) }

  visit('/')

  # Checks for a golden image in `spec/goldens/index_page.png`.
  # If none exists (your first run), it will create one for you.
  goldens.verify('index_page')
}
```

See [`poll_spec`](https://github.com/jubishop/jubivote/blob/main/spec/apparition/poll_spec.rb) in [`JubiVote`](https://github.com/jubishop/jubivote) for a detailed example of this being used.

## Apps using tony-test

- [Tony](https://github.com/jubishop/tony)
- [JubiVote](https://github.com/jubishop/jubivote)

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
