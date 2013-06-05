require 'bundler/capistrano'

set :application, "data-tracker"
set :repository,  "git@github.com:tolien/data-tracker.git"
set :domain, "ra.tolien.co.uk"

set :deploy_to, "/var/sites/#{application}" 

load 'deploy/assets'

# set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, domain                          # Your HTTP server, Apache/etc
role :app, domain                          # This may be the same as your `Web` server
role :db,  domain, :primary => true # This is where Rails migrations will run

# you might need to set this if you aren't seeing password prompts
default_run_options[:pty] = true
set :use_sudo, false

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
      run "cp #{current_path}/config/initializers/secret_token.rb.sample #{current_path}/config/initializers/secret_token.rb"
      run "cd #{current_path} && bundle exec rake secret:replace", :env => { :RAILS_ENV => rails_env }
      run "mkdir -p #{shared_path}/config; mv #{release_secret} #{shared_secret}"
    end
      
    # symlink secret token
    run "ln -nfs #{shared_secret} #{release_secret}"
  end
end

after "deploy:update", "deploy:symlink_secret"
