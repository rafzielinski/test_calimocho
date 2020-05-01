# config valid for current version and patch releases of Capistrano
lock "~> 3.11.0"

set :application, 'test_calimocho'
set :repo_url, 'git@github.com:primate-inc/test_calimocho.git'

set :rvm1_roles, [:web]

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, '/var/www/my_app_name'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:stage)}" }

# Default value for :linked_files is []
set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/master.key')

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/uploads', 'public/system', 'public/booking', 'public/uploads')

set :bundle_bins, fetch(:bundle_bins, []).push('delayed_job')
set :bundle_binstubs, -> { shared_path.join('bin') }

#set :rollbar_token, ''
#set :rollbar_role, Proc.new { :app }

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

Rake::Task['deploy:assets:precompile'].clear

namespace :deploy do

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

  namespace :assets do
    desc 'Compile assets'
    task :precompile => [:set_rails_env] do
      # invoke 'deploy:assets:precompile'
      invoke 'deploy:assets:precompile_local'
      invoke 'deploy:assets:backup_manifest'
    end

    desc "Precompile assets locally and then rsync to web servers"
    task :precompile_local do
      # remove existing packs directory
      run_locally { execute "rm -rf ./public/packs" }
      # compile assets locally
      run_locally do
        #execute "esvg --output 'app/assets/javascripts'"
        execute "WEBPACKER_PRECOMPILE=false RAILS_ENV=#{fetch(:stage)} bundle exec rake assets:precompile"
        execute "NODE_ENV=#{fetch(:stage)} bundle exec rails webpacker:compile"
      end

      # rsync to each server
      dirs = {
        './public/assets/' => 'public/assets/',
        './public/packs/' => 'public/packs/'
        # './public/javascripts/' => 'public/javascripts/'
      }
      on roles( fetch(:assets_roles, [:web]) ) do
        # this needs to be done outside run_locally in order for host to exist
        dirs.each do |local, remote|
          remote_dir = "#{host.user}@#{host.hostname}:#{release_path}/#{remote}"

          run_locally { execute "rsync -av -e 'ssh -p 30000' --delete #{local} #{remote_dir}" }
        end
      end

      # clean up
      run_locally { execute "rm -rf #{dirs.keys.first}" }
      run_locally { execute "rm -rf ./public/packs" }
      run_locally { execute "rm -rf ./public/javascripts" }
      #run_locally { execute "rm ./app/assets/javascripts/svgs.js" }
    end
  end

end

namespace :rvm1 do
  task :update_rvm_key do
    on roles :web do
      execute :gpg, "--keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB"
    end
  end

  task :install_missing_packages do
    on roles :web do
      # within fetch(:release_path) do
      #   # execute "#{fetch(:rvm1_auto_script_path)}/rvm-auto.sh", "rvm", "pkg install openssl"
      #   # execute "#{fetch(:rvm1_auto_script_path)}/rvm-auto.sh", "rvm", "autolibs rvm_pkg"
      # end
    end
  end

  namespace :install do
    desc "Installs Ruby for the given ruby project"
    task :ruby_custom_install do
      on roles :web do
        # within fetch(:release_path) do
        #   execute "#{fetch(:rvm1_auto_script_path)}/rvm-auto.sh", "rvm", "--install", "install", fetch(:rvm1_ruby_version), "-C --with-openssl-dir=$HOME/.rvm/usr"
        # end
      end
    end

    desc 'Install gems from Gemfile into gemset using Bundler.'
    task :gems do
      on roles(:web) do
        within fetch(:release_path) do
          execute :bundle, 'install', '--without development test'
        end
      end
    end
  end

  desc "Install Bundler" # https://github.com/rvm/rvm1-capistrano3/issues/45
  task :install_bundler do
    on roles :web do
      execute "cd #{release_path} && #{fetch(:rvm1_auto_script_path)}/rvm-auto.sh . gem install bundler"
    end
  end
end
before "rvm1:install:rvm", "rvm1:update_rvm_key"
before 'deploy', 'rvm1:install:rvm'
after 'rvm1:install:rvm', 'rvm1:install_missing_packages'
before 'deploy', 'rvm1:install:ruby_custom_install'
before 'rvm1:install:gems', 'rvm1:install_bundler'

Rake::Task['rvm1:install:gems'].clear_actions
namespace :rvm1 do
  namespace :install do
    desc 'Install gems from Gemfile into gemset using Bundler.'
    task :gems do
      on roles(:web) do
        within fetch(:release_path) do
          execute :bundle, 'install', '--without development test'
        end
      end
    end
  end
end
before 'deploy', 'rvm1:install:gems'
#after 'deploy', 'sitemap:create'
