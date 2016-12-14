# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'chaos_conoha/version'

Gem::Specification.new do |spec|
  spec.name          = "chaos_conoha"
  spec.version       = ChaosConoha::VERSION
  spec.authors       = ["kinoppyd"]
  spec.email         = ["WhoIsDissolvedGirl+github@gmail.com"]

  spec.summary       = %q{Sugoi zashikiwarashi}
  spec.description   = %q{Seiso kawaii zashikiwarasi}
  spec.homepage      = "https://github.com/kinoppyd/chaos_conoha"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "conoha_api", "~> 0.2"
  spec.add_dependency "slack-ruby-client", "~> 0.7"
  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest"
end
