# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "EnziTestRailUtility/version"

Gem::Specification.new do |spec|
  spec.name          = "EnziTestRailUtility"
  spec.version       = EnziTestRailUtility::VERSION
  spec.authors       = ["Monika Pingale"]
  spec.email         = ["monika.pingale@enzigma.in"]

  spec.summary       = "This gem will integrate ruby with testRail"
  spec.description   = "This gem is used to run suits, projets and cases written in testRail from ruby"
  spec.license       = "MIT"

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
end
