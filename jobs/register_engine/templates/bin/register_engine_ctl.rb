#!/var/vcap/bosh/bin/ruby

require 'rubygems'
require 'rubygems/dependency_installer'
require 'fileutils'

Gem::DependencyInstaller.new.install 'daemons'
require 'daemons'

log_dir="/var/vcap/sys/log/register_engine"
run_dir="/var/vcap/sys/run/register_engine"

FileUtils.mkdir_p log_dir
FileUtils.mkdir_p run_dir

Daemons.run File.join(File.dirname(__FILE__), 'register_engine.rb'),
  # :app_name => 'register_engine'
  :dir_mode => :normal,
  :dir => run_dir,
  :logfilename => "#{log_dir}/register_engine.log",
  :log_output => true
