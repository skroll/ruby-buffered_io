# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'buffered_io/version'

Gem::Specification.new do |gem|
  gem.name          = 'buffered_io'
  gem.version       = BufferedIO::VERSION
  gem.authors       = ['Scott M. Kroll']
  gem.email         = ['skroll@gmail.com']
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""
  gem.has_rdoc      = true
  gem.rdoc_options = ['--line-numbers', '--inline-source', '--title', 'BufferedIO', '--main', 'README.rdoc']

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']
end

