lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "shd/version"

Gem::Specification.new do |spec|
  spec.name          = "stations-human-diff"
  spec.version       = SHD::VERSION
  spec.authors       = ["Kevin Soltysiak"]
  spec.email         = ["kevin.soltysiak@trainline.com"]

  spec.summary       = "Pretty print stations.csv diffs"
  spec.description   = "Pretty print stations.csv diffs of pull requests"
  spec.homepage      = "https://trainline.eu"
  spec.license       = "MIT"

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler",  "~> 1.16"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "pry",      "~> 0.11.0"
  spec.add_development_dependency "rake",     "~> 10.0"
  spec.add_runtime_dependency     "jwt",      "~> 2.1", ">= 2.1.0"
  spec.add_runtime_dependency     "octokit",  "~> 4.8", ">= 4.8.0"
end
