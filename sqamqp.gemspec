# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "sqamqp/version"

Gem::Specification.new do |spec|
  spec.name          = "sqamqp"
  spec.version       = Sqamqp::VERSION
  spec.authors       = ["Ilya Rogozin"]
  spec.email         = ["i.rogozin@socialquantum.com"]

  spec.summary       = %q{for internal usage}
  spec.description   = %q{shared classes for amqp}
  spec.homepage      = "https://gitlab2.sqtools.ru/sqerp/amqp"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "bunny", "~> 2.6.6"
  spec.add_dependency "connection_pool", ">= 1.0.0"

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
