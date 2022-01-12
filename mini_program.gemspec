require_relative "lib/mini_program/version"

Gem::Specification.new do |spec|
  spec.name        = "mini_program"
  spec.version     = MiniProgram::VERSION
  spec.authors     = ["ian"]
  spec.email       = ["ianlynxk@gmail.com"]
  spec.homepage    = "https://github.com/bkyz/mini_program"
  spec.summary     = "a engine for develop mini program"
  spec.description = "include login, send subscribe message, get phone number function of mini program"
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage + "/CHANGELOG.md"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  # spec.add_dependency "rails", "~> 6.1.4"
  spec.add_dependency "rails", "~> 7.0.1"
  spec.add_dependency "mocha"
end
