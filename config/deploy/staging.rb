set :application, "data-tracker-test"
set :domain, "camulus.tolien.co.uk"

set :deploy_to, "/var/sites/#{application}" 

role :web, domain                          # Your HTTP server, Apache/etc
role :app, domain                          # This may be the same as your `Web` server
role :db,  domain, :primary => true # This is where Rails migrations will run

# you might need to set this if you aren't seeing password prompts
default_run_options[:pty] = true
set :use_sudo, false
