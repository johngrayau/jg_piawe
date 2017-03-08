 Gem::Specification.new do |s|
  s.name        = 'jg_piawe'
  s.version     = '0.0.0'
  s.date        = '2017-03-08'
  s.summary     = "PIAWE calculator"
  s.description = "A simple calculator for PIAWE based payments"
  s.authors     = ["John Gray"]
  s.email       = 'foo@bar.com'
  s.files       = ["lib/piawe.rb"]
  s.homepage    = 'http://rubygems.org/gems/jg_piawe'
  s.license       = 'GPL-3.0'
	s.add_runtime_dependency "role_playing", ["= 0.1.5"]
end
