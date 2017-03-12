# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'piawe/version'

Gem::Specification.new do |spec|
  spec.name          = 'jg_piawe'
  spec.version       = Piawe::VERSION
  spec.authors       = ["John Gray"]
  spec.email         = 'foo@bar.com'
  spec.date          = '2017-03-08'

  spec.summary       = "PIAWE calculator"
  spec.description   = "A simple calculator for PIAWE based payments"
  spec.homepage      = 'http://rubygems.org/gems/jg_piawe'
  spec.license       = 'GPL-3.0'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "rspec-context-private"
  spec.add_runtime_dependency "role_playing", ["= 0.1.5"]
end
