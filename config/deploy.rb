set :application, "open-active-democracy"
set :domain, "skuggathing.is"
set :selected_branch, "master"
set :repository, "git://github.com/rbjarnason/open-active-democracy.git"
set :use_sudo, false
set :deploy_to, "/home/robert/sites/#{application}/#{selected_branch}"
set :branch, "#{selected_branch}"
set :user, "robert"
set :deploy_via, :remote_cache

set :scm, "git"

role :app, domain
role :web, domain
role :db,  domain, :primary => true

task :after_update_code do
  run "ln -s #{deploy_to}/#{shared_dir}/config/database.yml #{current_release}/config/database.yml"
  run "ln -s #{deploy_to}/#{shared_dir}/config/facebooker.yml #{current_release}/config/facebooker.yml"
  run "ln -s #{deploy_to}/#{shared_dir}/config/newrelic.yml #{current_release}/config/newrelic.yml"
  run "ln -s #{deploy_to}/#{shared_dir}/production #{current_release}/public/production"
  run "ln -s #{deploy_to}/#{shared_dir}/private #{current_release}/private"
  run "ln -s #{deploy_to}/#{shared_dir}/solr #{current_release}/solr"
  run "ln -s #{deploy_to}/#{shared_dir}/solr_java #{current_release}/vendor/plugins/acts_as_solr/solr"
  #run "rm -f #{current_path}"
end

namespace :deploy do
  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end
end

deploy.task :start do
# nothing
end


Dir[File.join(File.dirname(__FILE__), '..', 'vendor', 'gems', 'hoptoad_notifier-*')].each do |vendored_notifier|
  $: << File.join(vendored_notifier, 'lib')
end

require 'hoptoad_notifier/capistrano'
