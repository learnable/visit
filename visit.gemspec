# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "visit/version"

Gem::Specification.new do |s|
  s.name        = "visit"
  s.version     = Visit::VERSION
  s.authors     = ["Leni Mayo"]
  s.email       = ["leni@learnable.com"]
  s.homepage    = ""
  s.summary     = %q{Record visits to a site so that they're easy to analyse afterward.}
  s.description = %q{Based on Learnable visit events}

  s.rubyforge_project = "visit"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_runtime_dependency "rest-client"

  s.add_development_dependency "rspec"
end
