#!/usr/bin/env ruby
#
#    <Quantitative project management tool.>
#    Copyright (C) 2012 IPA, Japan.
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

#
#= Create Master Project Data
#

$:.unshift(File.dirname(File.expand_path(__FILE__)))
require 'lib/new_ipf_project'
require 'lib/lockfile'
require 'tmpdir'
require 'yaml'
require 'pp'


config = YAML.load(File.open(File.expand_path('../config/ipf_data_insert_settings.yml', __FILE__)))

# check lock file
lock_file = File.join(Dir.tmpdir, 'ipf_data_insert.lock')
if File.exist?(lock_file)
  puts 'Another process executing.'
  exit(1)
end

# create lock object
lock_object = Lockfile.new(lock_file)

begin
  # create logging object
  logfile = File.join(config['config']['log_dir'], File.basename(__FILE__, ".*")) + ".log"
  logger = Logger.new(logfile)

  unless lock_object.lock
    puts 'Lock failed.'
    logger.error('Lock failed.')
    exit(1)
  end

  ActiveRecord::Base.logger = logger
  ActiveRecord::Base.colorize_logging = false
  ActiveRecord::Base.logger.datetime_format = "%Y/%m/%d %H:%M:%S"

  # connect to Redmine DB
  ActiveRecord::Base.establish_connection(config['database'].merge(:adapter => 'postgresql'))

  # collect master project data
  master_project_data = NewIpfProject::collect_for_master_project(config['config']['master_project_path'])
  if master_project_data.nil?
    logger.error('Master project not found.')
    exit(1)
  end

  # check master project existing
  if Project.exists?(master_project_data["project"]["identifier"])
    puts("Master Project already exists.")
    logger.error("Master Project already exists.")
    # no error
    exit(0)
  end

  # create project to DB
  ActiveRecord::Base.transaction do
    NewIpfProject::create_new_project(master_project_data)
  end
rescue => err
  raise
ensure
  if ActiveRecord::Base.connected?
    ActiveRecord::Base.connection.disconnect!
  end
  lock_object.unlock
end

exit(0)
