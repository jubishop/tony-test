Gem::Specification.new do |spec|
  spec.name          = 'tony-test'
  spec.version       = '0.41'
  spec.summary       = %q(Helpers for testing Tony.)
  spec.authors       = ['Justin Bishop']
  spec.email         = ['jubishop@gmail.com']
  spec.homepage      = 'https://github.com/jubishop/tony-test'
  spec.license       = 'MIT'
  spec.files         = Dir['lib/**/*.*']
  spec.require_paths = ['lib']
  spec.bindir        = 'bin'
  spec.executables   = []
  spec.metadata      = {
    'source_code_uri' => 'https://github.com/jubishop/tony-test',
    'rubygems_mfa_required' => 'true'
  }
  spec.required_ruby_version = Gem::Requirement.new('>= 3.0')
  spec.add_runtime_dependency('capybara')
  spec.add_runtime_dependency('chunky_png')
  spec.add_runtime_dependency('colorize')
  spec.add_runtime_dependency('puma')
  spec.add_runtime_dependency('rack')
  spec.add_runtime_dependency('rack-contrib')
  spec.add_runtime_dependency('rack-test')
  spec.add_runtime_dependency('rspec')
end
