# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "protocolist/version"

Gem::Specification.new do |s|
  s.name        = "protocolist"
  s.version     = Protocolist::VERSION
  s.authors     = ["Dmitry Yakimov"]
  s.email       = ["welldan97@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Activity feeds solution for Rails.}
  s.description = %q{Simple activity feeds solution for Rails applications. Gives a flexible way to build activity feeds infrastructure over it. }

  s.rubyforge_project = "protocolist"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 2.9.0'
  s.add_development_dependency 'guard-rspec', '~> 0.7.0'
  s.add_development_dependency 'supermodel', '~> 0.1.6'
  s.add_development_dependency 'psych', '~> 1.2.2' # fixes ' superclass mismatch for class Mark ' error
  s.add_development_dependency 'railties', '~> 3.0'
end
