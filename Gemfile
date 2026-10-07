# frozen_string_literal: true

source "https://rubygems.org"

gemspec

gem "ffi", "~> 1.17", platforms: :jruby

gem "irb"
gem "maxitest", "~> 7.1"
gem "rake", "~> 13.0"
gem "rubocop", "~> 1.21"

install_if -> { RUBY_ENGINE != "jruby" } do
  gem "rake-compiler", "~> 1.2"
  gem "rake-compiler-dock", "~> 1.11"
end
