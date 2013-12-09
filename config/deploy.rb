require 'bundler/capistrano'

set :stages, %w(production staging)
set :default_stage, "staging"
require 'capistrano/ext/multistage'

load 'deploy/assets'

set :repository,  "git@github.com:tolien/data-tracker.git"

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
  task :seed do
    run "cd #{current_path}; #{rake} db:seed RAILS_ENV=#{rails_env}"
  end

  task :symlink_secret, :roles => :app, :except => { :no_release => true } do
    filename = 'secret_token.rb'
    release_secret = "#{release_path}/config/initializers/#{filename}"
    shared_secret = "#{shared_path}/config/#{filename}"
      
    if capture("[ -f #{shared_secret} ] || echo missing").start_with?('missing')
      run "cp #{release_path}/config/initializers/secret_token.rb.sample #{release_path}/config/initializers/secret_token.rb"
      run "cd #{release_path} && bundle exec rake secret:replace", :env => { :RAILS_ENV => rails_env }
      run "mkdir -p #{shared_path}/config; mv #{release_secret} #{shared_secret}"
    end
      
    # symlink secret token
    run "ln -nfs #{shared_secret} #{release_secret}"
  end
  
  desc "Symlink shared configs for the database."
  task :symlink_db do
    run "rm #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
end

after "deploy:update", "deploy:migrate"
before "deploy:finalize_update", "deploy:symlink_db", "deploy:symlink_secret"
