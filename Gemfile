source 'https://rubygems.org'

# hold at 5.1.1 for now
gem 'rails', '5.1.1'
gem 'sqlite3', group: [:test, :development]


# Gems used only for assets and not required
# in production environments by default.
gem 'sass-rails'
gem 'coffee-rails'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

gem 'uglifier', '>= 1.3.0'

gem 'jquery-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
group :development do
  gem 'capistrano', '~> 3.0', require: false
  gem 'capistrano-rails',   '~> 1.1', require: false
  gem 'capistrano-bundler', '~> 1.1', require: false
  gem 'capistrano-rvm'
  gem 'capistrano-passenger'
end

# To use debugger
# gem 'debugger'

gem 'devise', '~> 4.2'
gem 'immigrant'
gem 'jc-validates_timeliness'
gem 'pg', require: false
gem 'mysql2', group: [:test], require: false

gem 'bootstrap-sass'
gem "friendly_id"

gem 'factory_girl_rails', group: [:test]
gem 'will_paginate'
gem 'bootstrap-will_paginate'
gem 'activerecord-import'

gem 'google-analytics-rails'

gem 'acts_as_list'
gem 'dotiw'
gem 'simplecov', require: false, group: [:test]
gem 'd3-rails'

gem 'delayed_job_active_record'
gem 'rails-controller-testing'

gem 'jquery-ui-rails'

gem 'sprockets'
gem 'active_model_serializers'
gem 'daemons'
gem 'capistrano3-delayed-job'

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
