$:.push File.expand_path("../lib", __FILE__)
require "swiftype-app-search/version"

Gem::Specification.new do |s|
  s.name        = "swiftype-app-search"
  s.version     = SwiftypeAppSearch::VERSION
  s.authors     = ["Quin Hoxie"]
  s.email       = ["support@swiftype.com"]
  s.homepage    = "https://swiftype.com"
  s.summary     = %q{Official gem for accessing the Swiftype App Search API}
  s.description = %q{API client for accessing the Swiftype App Search API with no dependencies.}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'rspec', '~> 3.0.0'
  s.add_development_dependency 'awesome_print'
  s.add_development_dependency 'webmock'

  s.add_runtime_dependency 'jwt', '~> 1.5.1'
end
