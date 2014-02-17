# -*- encoding: utf-8 -*-
require File.expand_path('../lib/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Will Brown']
  gem.email         = ['mail@willbrown.name']
  gem.description   = 'Tools for working with MPO format stereoscopic 3D images'
  gem.summary       = 'Tools for working with MPO format stereoscopic 3D images'
  gem.homepage      = 'https://github.com/rawls/mpo_tools'
  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "mpo_tools"
  gem.require_paths = ["lib"]
  gem.version       = MpoTools::VERSION
  gem.platform      = Gem::Platform::RUBY
  gem.date          = '2014-02-07'
  gem.license       = 'MIT'

  gem.required_ruby_version = '>= 1.9.2'
  gem.extra_rdoc_files = ['README.md']

  gem.add_runtime_dependency 'rmagick'

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rake-notes'
end
