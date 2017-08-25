# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'erdf/version'

Gem::Specification.new do |spec|
  spec.name          = "erdf"
  spec.version       = Erdf::VERSION
  spec.authors       = ["David Strauß", "Kishorekumar Neelamegam"]
  spec.email         = ["david@strauss.io", "nkishore@megam.io"]

  spec.summary       = %q{Entity-Relationship-Diagramm-Erzeuger}
  spec.description   = %q{Generate good looking Entity-Relationship-Diagrams from text files or a PostgreSQL database.}
  spec.homepage      = "https://github.com/megamsys/erde"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.executables   = "erdf"
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "minitest", "~> 5.10"

  spec.add_dependency "sequel", "~> 4.0"
end
