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

  s.add_dependency("rails", "= 3.2.12")
  #s.add_dependency("activesupport", "~> 3.0")
  s.add_dependency("i18n")
  s.add_dependency("schema_plus")

  # Dependencies for dev/testing of the actual gem. Test gems are required
  # manually in spec_helper.
  s.add_development_dependency("rspec-rails")
  s.add_development_dependency("factory_girl_rails")

  # NOTE dependencies for the dummy app are in the Gemfile
end
