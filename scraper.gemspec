# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'scraper/version'

Gem::Specification.new do |spec|
  spec.name          = "scraper"
  spec.version       = Scraper::VERSION
  spec.authors       = ["Nick Lalic"]
  spec.email         = ["nick.lalic@gmail.com"]

  spec.summary       = %q{Simple base class that manages cookies only}
  spec.description   = %q{Simple base class that manages cookies. Can be used to login to site to scrape}
  spec.homepage      = "https://www.github.com/Terrabits/scraper"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler",  "~> 1.12"
  spec.add_development_dependency "rake",     "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"

  spec.add_runtime_dependency     "Pry",      "~> 0.10",  ">= 0.10.4"
  spec.add_runtime_dependency     "HTTParty", "~> 0.14.0"
  spec.add_runtime_dependency     "Nokogiri", "~> 1.6",   ">= 1.6.8"
end