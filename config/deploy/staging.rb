set :stage, :staging
set :branch, :staging
set :deploy_to, '/var/www/staging/test_calimocho'
set :rvm1_ruby_version, '2.5.5'

# set :default_env, { rvm_path: '/usr/local/rvm' }
# set :rvm1_map_bins, %w(rake gem bundle ruby honeybadger)

role :app, %w{test_calimocho-staging.canneroni.com}
role :web, %w{test_calimocho-staging.canneroni.com}
role :db,  %w{test_calimocho-staging.canneroni.com}

set :rails_env, 'staging'
# server-based syntax
# ======================
# Defines a single server with a list of roles and multiple properties.
# You can define all roles on a single server, or split them:
server 'test_calimocho-staging.canneroni.com', user: 'deployer', roles: %w{web app}

set :ssh_options, {
  user: 'deployer',
  keys: %w(/Users/bart/.ssh/id_rsa /Users/Colin/.ssh/id_rsa /Users/rafalzielinski/.ssh/id_rsa /Users/bartlomiejoleszczyk/.ssh/id_rsa /Users/gordonmclachlan/.ssh/id_rsa C:\Users\Gordon\.ssh\id_rsa /Users/freelance2/.ssh/id_rsa /home/piotrek/.ssh/id_rsa /Users/primate/.ssh/id_rsa /Users/christopherlamb/.ssh/id_rsa),
  forward_agent: false,
  port: 30000
}
set :assets_roles, [:web, :app]

# Defaults to 'assets'
# # This should match config.assets.prefix in your rails config/application.rb
#

set :passenger_restart_command, "touch #{deploy_to}/current/tmp/restart.txt"
set :passenger_restart_options, -> { "" }

# before "bundler:install", "bundler:config_update"

namespace :bundler do
  desc 'Set bundler variables'
  task :config_update do
    on roles(:web) do
      execute "bundle config build.pg --with-pg-config=/usr/pgsql-9.6/bin/pg_config"
    end
  end
end
