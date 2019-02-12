source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.1'

gem 'rails', '~> 5.2.2'
gem 'pg', '~> 1.1', '>= 1.1.3'
gem 'puma', '~> 3.11'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'rails_event_store', '~> 0.35.0'

group :development, :test do
  gem 'pry-byebug', '~> 3.6'
  gem 'dotenv-rails', '~> 2.2', '>= 2.2.1'
  gem 'rubocop', '~> 0.61.1'
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'rspec-rails', '~> 3.8', '>= 3.8.1'
  gem 'database_cleaner', '~> 1.7'
  gem 'rails_event_store-rspec', '~> 0.35.0'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
