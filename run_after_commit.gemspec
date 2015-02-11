# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'run_after_commit/version'

Gem::Specification.new do |spec|
  spec.name          = "run_after_commit"
  spec.version       = RunAfterCommit::VERSION
  spec.authors       = ["Benjamin Vetter"]
  spec.email         = ["vetter@plainpicture.de"]
  spec.summary       = %q{Run code in an ActiveRecord model after it is committed}
  spec.description   = %q{Run code in an ActiveRecord model after it is committed}
  spec.homepage      = "https://github.com/mrkamel/run_after_commit"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "activerecord", ">= 3.0.0"
  spec.add_development_dependency "appraisal"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "hooks"
end
