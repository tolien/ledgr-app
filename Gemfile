source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0'
# Use sqlite3 as the database for Active Record
gem 'sqlite3', group: [:test, :development]
# Use Puma as the app server
gem 'puma', '~> 3.12', group: [:test, :development]
# Use SCSS for stylesheets
gem 'sassc-rails'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby


# Use CoffeeScript for .coffee assets and views
# gem 'coffee-rails'

gem 'jquery-rails'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# To use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '~> 2.13'
  gem 'selenium-webdriver'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

## Custom gems
# Use Capistrano for deployment
group :development do
  gem 'capistrano', '~> 3.0', require: false
  gem 'capistrano-rails',   '~> 1.1', require: false
  gem 'capistrano-bundler', '~> 1.1', require: false
  gem 'capistrano-rvm'
  gem 'capistrano-passenger'
  gem 'capistrano-yarn'
  gem 'ed25519'
  gem 'bcrypt_pbkdf'
end

gem 'devise'
gem 'immigrant'
gem 'jc-validates_timeliness'
gem 'pg', '< 1.0.0', require: false
gem 'mysql2', '~> 0.4.0', group: [:test], require: false

gem 'bootstrap-sass'
gem "friendly_id"

gem 'factory_bot_rails', group: [:test]
gem 'will_paginate'
gem 'bootstrap-will_paginate'
gem 'activerecord-import'

gem 'acts_as_list'
gem 'dotiw'
gem 'simplecov', require: false, group: [:test]

gem 'delayed_job_active_record'
gem 'rails-controller-testing'

gem 'jquery-ui-rails'
gem 'devise-two-factor'

gem 'sprockets', '~> 4.0'
gem 'active_model_serializers'
gem 'daemons'
gem 'capistrano3-delayed-job'
gem 'bootsnap', require: false

gem 'codecov', :require => false, :group => :test
gem 'webpacker', '~> 4.0'

gem 'doorkeeper', '~> 5.2.0.rc3' #github: 'doorkeeper-gem/doorkeeper'
