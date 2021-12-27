# tony-test

[![Rubocop Status](https://github.com/jubishop/tony-test/workflows/Rubocop/badge.svg)](https://github.com/jubishop/tony-test/actions/workflows/rubocop.yml)

Helpers for testing [Tony](https://github.com/jubishop/tony).

## Installation

### In a Gemfile

```ruby
source: 'https://www.jubigems.org/' do
  gem 'core-test'
  gem 'tony-test'
end
```

## RSpec

`tony-test` is designed for use with [`RSpec`](https://rspec.info) on top of either [`rack-test`](https://github.com/rack/rack-test) for basic http testing, or [`capybara`](https://github.com/teamcapybara/capybara) for testing inside a Chrome browser, with Javascript support and the ability to capture screenshots.

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

RSpec.configure do |config|
  config.include_context(:rack_test, type: :rack_test)
end
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

    # You can wait until fontawesome has loaded.
    expect(last_response.body).to(have_fontawesome)

    # You can wait until the timezone has been loaded.
    expect(last_response.body.to(have_timezone)
  }

  # You can simply assert a slim template is rendered with specific params.
  it('just tests a slim render is called') {
    # All the keys must be passed to a Slim template at `my_template`.
    # Note how you can use RSpec matchers here, or simple items for == testing.
    expect_slim(:my_template, param: contains('some substr'),
                              another: an_instance_of(MyClass),
                              values: match_array(['tony', 'bennett']),
                              other: 'exact match')
    get '/'
  }

  # You can also pass the specific keys `layout:` and `views:` to insist the
  # slim template includes a specific layout and comes from a specific views
  # directory.
  it('tests a slim render has specific view and layout') {
    expect_slim(:template_name, views: 'view_dir', layout: 'our_layout_file')
    get '/'
  }
}
```

### Capybara

In your `spec_helper.rb`:

```ruby
require `tony-test`

# Of course you need to set Capybara.app here and call Capybara.register_driver
# and anything else to set up Capybara as per its documentation.

RSpec.shared_context(:capybara) do
  include_context(:tony_capybara)

  let(:cookie_secret) {
    # Return the same cookie secret string the app will be using.
  }
end

RSpec.configure do |config|
  config.include_context(:capybara, type: :feature)
end
```

Now in any individual `_spec.rb` test file:

```ruby

# `type: :feature` will pull in all the helpers for capybara.
RSpec.describe(MyTonyApp, type: :feature) {
  it('does something') {
    # You can set cookies
    set_cookie(:key, 'value')

    # Standard stuff you do in capybara
    visit('/')

    # All standard Capybara matchers are available
    expect(page).to(have_selector('p.class'))

    # You can wait until fontawesome has loaded.
    expect(page).to(have_fontawesome)

    # You can wait until the timezone has been loaded.
    expect(last_response.body.to(have_timezone)
  }
}
```

### Screenshot Goldens

`tony-test` offers a system for storing "golden" screenshots of your app which it can test for changes during a test run.  If any screenshots have changed, it will launch its own local `Tony` webserver and open a browser where you can review those changes and choose whether to accept the new images as the new goldens.  If you accept, it will copy the new image into your git repo, overwriting the original.

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

#### Ensuring Fontawesome is Loaded

`tony-test` by default will always expect the page to `have_fontawesome` before screenshotting any golden.  In particular it will wait for the `SVG` version of fontawesome to load by watching for the class `fontawesome-i2svg-complete`.  If you're not using `fontawesome`, you can pass `expect_fontawesome: false` to `goldens.verify()` to disable.

#### Screenshot Variance Tolerance

Screenshots may differ slightly from environment to environment.  You can tell `tony-test` to allow a certain amount of variability by setting the `ENV['GOLDENS_PIXEL_TOLERANCE']`.  The value represents a percentage, so `5` means an allowance of 5% difference between the golden and the current screenshot.

#### Hard Failing Screenshots

In some scenarios you may want `tony-test` to hard fail if a golden does not match.  You can enable this by setting `ENV['FAIL_ON_GOLDEN']` to any value.  In `Github Actions` this will happen by default with no need to set any environment value.

#### Saving Screenshots as Artifacts In `Github Actions`

When in `Github Actions`, `tony-test` will save your screenshots in a sub `failures` folder inside your original goldens folder.  It will also generate and save a "diff" image visualizing the differences in a `diffs` folder.  You can then add these files to your artifacts so you can view the failures.

#### Full `Github Actions` Example

Here is how you could use all your options to set things up inside `Github Actions`:

```yaml
- name: Check out code
  uses: actions/checkout@v2
- name: Set up Ruby
  uses: ruby/setup-ruby@v1.87.0
  with:
    ruby-version: 3.0.2
    bundler-cache: true
- name: Run tests
  run: |
    bundle exec rake spec
  env:
    APP_ENV: test
    GOLDENS_PIXEL_TOLERANCE: 0.05
    RACK_ENV: test
- name: Upload screenshots
  uses: actions/upload-artifact@v2
  if: failure()
  with:
    name: golden-failures
    path: |
      spec/**/failures/*.png
      spec/**/diffs/*.png
    if-no-files-found: ignore
```

## More Documentation

- [Rubydoc](https://www.rubydoc.info/github/jubishop/tony-test/master)

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
