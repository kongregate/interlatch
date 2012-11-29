# -*- encoding: utf-8 -*-
require File.expand_path('../lib/interlatch/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Drew Chandler", "Pete Keen"]
  gem.email         = ["drew@kongregate.com", "pkeen@kongregate.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "interlatch"
  gem.require_paths = ["lib"]
  gem.version       = Interlatch::VERSION

  gem.add_dependency('activesupport', '>= 3.0')
  gem.add_dependency('actionpack', '>= 3.0')
  gem.add_dependency('railties', '>= 3.0')
end
