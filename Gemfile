source 'https://rubygems.org'

# Declare your gem's dependencies in accounts-rails.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# TODO remove once OSU 5.1.1 published
gem 'openstax_utilities', path: '../openstax_utilities'

# jquery-rails is used by the dummy application
gem 'jquery-rails'

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# To use debugger
gem 'byebug'

rails_version = ENV['RAILS_VERSION'] || 'default'

rails = case rails_version
when 'master'
  [ { github: 'rails/rails' } ]
when 'default'
  []
else
  [ "~> #{rails_version}" ]
end

gem 'rails', *rails
