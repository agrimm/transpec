# coding: utf-8

require_relative 'lib/transpec_test'

namespace :test do
  # On Travis CI, reuse system gems to speed up build.
  bundler_args = if ENV['TRAVIS']
                   []
                 else
                   %w(--path vendor/bundle)
                 end

  # rubocop:disable LineLength
  tests = [
    TranspecTest.new(File.expand_path('.'), nil, ['--quiet']),
    TranspecTest.new('https://github.com/yujinakayama/twitter.git', 'transpec-test-rspec-2-99', bundler_args),
    TranspecTest.new('https://github.com/yujinakayama/mail.git', 'transpec-test-rspec-2-99', bundler_args)
  ]

  # Sometimes Guard fails with JRuby randomly.
  unless RUBY_ENGINE == 'jruby'
    tests << TranspecTest.new('https://github.com/yujinakayama/guard.git', 'transpec-test-rspec-2-99', bundler_args + %w(--without development))
  end
  # rubocop:enable LineLength

  desc 'Test Transpec on all projects'
  task all: tests.map(&:name)

  tests.each do |test|
    desc "Test Transpec on #{test.name} project"
    task test.name do
      test.run
    end
  end
end
