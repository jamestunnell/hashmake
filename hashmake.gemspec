# -*- encoding: utf-8 -*-

require File.expand_path('../lib/hashmake/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "hashmake"
  gem.version       = Hashmake::VERSION
  gem.summary       = %q{Make hashed-based object initialization easy!}
  gem.description   = %q{Make hash-based object initialization easy! Provides hash_make method that can consider parameter name, type, default value, validation, and requiredd/not, according to the specification provided. Also, by default assigns by default to instance variable of same name as parameter.}
  gem.license       = "MIT"
  gem.authors       = ["James Tunnell"]
  gem.email         = "jamestunnell@lavabit.com"
  gem.homepage      = "https://rubygems.org/gems/hashmake"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_development_dependency 'bundler', '~> 1.0'
  gem.add_development_dependency 'rake', '~> 0.8'
  gem.add_development_dependency 'rdoc', '~> 3.0'
  gem.add_development_dependency 'rspec', '~> 2.4'
end
