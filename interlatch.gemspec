# -*- encoding: utf-8 -*-
require File.expand_path('../lib/interlatch/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Drew Chandler", "Pete Keen"]
  gem.email         = ["drew@kongregate.com", "pkeen@kongregate.com"]
  gem.description   = %q{Rails 3+ Interlock replacement}
  gem.summary       = %q{Coordinates cached view fragments and controller blocks}
  gem.homepage      = "https://github.com/kongregate/interlatch"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "interlatch"
  gem.require_paths = ["lib"]
  gem.version       = Interlatch::VERSION

  gem.add_dependency('activesupport', '>= 3.0', '< 5.0')
  gem.add_dependency('actionpack', '>= 3.0', '< 5.0')
  gem.add_dependency('activerecord', '>= 3.0', '< 5.0')
  gem.add_dependency('railties', '>= 3.0', '< 5.0')

  gem.add_development_dependency('sqlite3', '>= 1.3.6')
  gem.add_development_dependency('byebug', '>= 6.0.0', '< 7.0')
end
