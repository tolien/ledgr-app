lock '3.6.0'

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
 set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system public/assets}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Use 4 bundler threads in parallel when installing gems
set :bundle_jobs, 4

# set Rails environment to production
set :rails_env, "production"

namespace :deploy do
  desc 'Compile assets'
  task :compile_assets => [:set_rails_env] do
    # invoke 'deploy:assets:precompile'
    invoke 'deploy:assets:precompile_local'
    # invoke 'deploy:assets:backup_manifest'
  end
  
  after :updated, "deploy:compile_assets"
  
  namespace :assets do
    
    desc "Precompile assets locally and then rsync to web servers" 
    task :precompile_local do 
      # compile assets locally
      run_locally do
        execute "RAILS_ENV=#{fetch(:rails_env)} bundle exec rake assets:precompile"
      end
 
      # rsync to each server
      local_dir = "./public/assets/"
      on roles( fetch(:assets_roles, [:web]) ) do
        # this needs to be done outside run_locally in order for host to exist
        remote_dir = "#{host.user}@#{host.hostname}:#{release_path}/public/assets/"
    
        run_locally { execute "rsync -av --delete #{local_dir} #{remote_dir}" }
      end
 
      # clean up
      run_locally { execute "rm -rf #{local_dir}" }
    end    
  end

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end
  
  after deploy:publishing, deploy:restart_delayed_job
  task :restart_delayed_job do
    invoke 'delayed_job:restart'
  end
end
