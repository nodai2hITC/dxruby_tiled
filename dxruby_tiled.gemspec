# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dxruby_tiled/version'

Gem::Specification.new do |spec|
  spec.name          = "dxruby_tiled"
  spec.version       = DXRuby::Tiled::VERSION
  spec.authors       = ["nodai2h-ITC"]
  
  spec.summary       = %q{Draw TiledMapEditor JSON data by using DXRuby.}
  spec.description   = %q{Draw TiledMapEditor JSON data by using DXRuby.}
  spec.homepage      = "https://github.com/nodai2hITC/dxruby_tiled"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  
  spec.add_dependency 'dxruby'
  spec.add_dependency 'json'
  
  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
end
