# frozen_string_literal: true

require_relative "lib/aws_ip_ranges/version"

Gem::Specification.new do |spec|
  spec.name          = "aws-ip-ranges"
  spec.version       = AwsIpRanges::VERSION
  spec.authors       = ["Yohan Robert"]
  spec.email         = ["yohan.robert@happydemics.com"]

  spec.summary       = "Retrieve AWS IP ranges with ease."
  spec.description   = "Retrieve AWS IP ranges with ease."
  spec.homepage      = "https://github.com/happydemics/aws-ip-ranges"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/happydemics/aws-ip-ranges"
  spec.metadata["changelog_uri"] = "https://github.com/happydemics/aws-ip-ranges/tree/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "dry-cli", "~> 0.7.0"
  spec.add_dependency "faraday", "~> 2.0"
  spec.add_dependency "faraday-retry", "~> 1.0"
  spec.metadata["rubygems_mfa_required"] = "true"
end
