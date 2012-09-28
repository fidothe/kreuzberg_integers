require 'bundler/capistrano'

default_run_options[:pty] = true

set :application, ENV['CAP_APP']
set :user, ENV['CAP_APP']
set :repository,  "git@github.com:fidothe/kreuzberg_integers.git"
set :rvm_ruby_string, ENV['CAP_RVM']
set :rvm_type, :system
set :use_sudo, false

require 'rvm/capistrano'

set :scm, :git
ssh_options[:forward_agent] = true
set :branch, "master"
set :deploy_via, :remote_cache
set :deploy_to, ENV['CAP_PATH']

server ENV['CAP_SERVER'], :web, :app, :db, :primary => true

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end
