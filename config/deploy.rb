set :application, 'ledgr-app'
set :repo_url, 'git@github.com:tolien/ledgr-app.git'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }
set :branch, ENV['BRANCH'] || :master

# Default deploy_to directory is /var/www/my_app
set :deploy_to, ->() { "/var/sites/#{fetch(:application)}" }

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :info

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
 set :linked_files, %w{config/database.yml config/initializers/secret_token.rb}

# Default value for linked_dirs is []
 set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system public/assets node_modules}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Use 4 bundler threads in parallel when installing gems
set :bundle_jobs, 4

# set Rails environment to production
set :rails_env, "production"

# no binstubs
set :bundle_binstubs, nil

# delayed_job config
set :delayed_job_workers, 1

after 'deploy:published', 'delayed_job:restart'
after 'deploy:published', 'bundler:clean'
