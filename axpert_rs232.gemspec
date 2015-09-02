Gem::Specification.new do |s|
  s.name        = 'axpert_rs232'
  s.version     = '1.0.3'
  s.date        = '2015-08-26'
  s.summary     = "Simplify communicating with a Voltronics Axpert range inverter"
  s.description = "Simplify communicating with a Voltronics Axpert range inverter"
  s.authors     = ["Johan van der Vyver"]
  s.email       = 'johan.vdvyver@gmail.com'
  s.files       = ["lib/axpert_commands.rb", "lib/axpert_constants.rb", "lib/voltronic_device_operation.rb", "lib/voltronic_rs232.rb", "lib/axpert_rs232.rb"]
  s.homepage    = 'http://rubygems.org/gems/axpert_rs232'
  s.license     = 'MIT'
  s.required_ruby_version = '>= 1.9.3'
end