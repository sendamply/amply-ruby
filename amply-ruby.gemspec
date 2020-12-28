lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'amply/version'

Gem::Specification.new do |spec|
  spec.name        = 'amply-ruby'
  spec.version     = Amply::VERSION
  spec.email       = 'support@sendamply.com'
  spec.authors     = ['Amply']
  spec.summary     = 'Amply Gem'
  spec.description = 'Amply Gem to Interact with Amply\'s API in native Ruby'
  spec.homepage    = 'https://github.com/sendamply/amply-ruby'

  spec.required_ruby_version = '>= 2.4'

  spec.license = 'MIT'
  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(/^bin/) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(/^(test|spec|features)/)
  spec.require_paths = ['lib']
end
