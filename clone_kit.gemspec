# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "clone_kit/version"

Gem::Specification.new do |spec|
  spec.name          = "clone_kit"
  spec.version       = CloneKit::VERSION
  spec.authors       = ["Brandon Croft"]
  spec.email         = ["brandon@kapost.com"]

  spec.summary       = "A toolkit to assist in complex cloning operations"
  spec.description   = "Supports rules-based cloning, Mongoid, and distributed operations"
  spec.homepage      = "https://github.com/kapost/clone_kit"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(spec)/})
  end

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r(^exe/)) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "activesupport", "> 3.0.0" # For core ext Array#wrap and Object#blank?
  spec.add_runtime_dependency "redis"

  spec.add_development_dependency "activerecord", "~> 4.0"
  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "combustion", "~> 0.7.0"
  spec.add_development_dependency "database_cleaner", "1.5.3"
  spec.add_development_dependency "fakeredis"
  spec.add_development_dependency "mongoid", "~> 4.0.2"
  spec.add_development_dependency "pg", "~> 0.18.4"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "rake", "~> 11.0"
  spec.add_development_dependency "rspec-collection_matchers"
  spec.add_development_dependency "rspec_junit_formatter", "~> 0.3"
  spec.add_development_dependency "rspec-rails", "~> 3.4"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "simplecov", "~> 0.12.0"
end
