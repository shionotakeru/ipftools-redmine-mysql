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
#= Create Sample Project
#

$:.unshift(File.dirname(File.expand_path(__FILE__)))
require 'lib/new_ipf_project'
require 'lib/sample_project_helper'
require 'lib/lockfile'
require 'tmpdir'
require 'yaml'

# read configuration
config = YAML.load(File.open(File.expand_path('../config/ipf_data_insert_settings.yml', __FILE__)))
sample_data_path = config['config']['sample_data_path']
pmdata_schema = "pm_data" # config['ipf_database']['pmdata_schema']

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
  logger.datetime_format = "%Y/%m/%d %H:%M:%S"
  logger.formatter = Logger::Formatter.new

  # do exclusive lock
  unless lock_object.lock
    puts 'Lock failed.'
    logger.error('Lock failed.')
    exit(1)
  end

  ActiveRecord::Base.logger = logger
  ActiveRecord::Base.colorize_logging = false

  helper = SampleProjectHelper.new

  puts 'creating sample project...'

  # connect to Redmine DB
  helper.connect(config['database'].merge(:adapter => 'postgresql')) do
    sample_project_params = {
      :name => 'IPF Sample Project',
      :identifier => 'ipfsampleproject',
    }

    # check master project existing
    if Project.exists?(sample_project_params[:identifier])
      puts("Sample Project already exists.")
      logger.error("Sample Project already exists.")
      # not error
      exit(0)
    end

    # collect master project data
    project_data = NewIpfProject::collect_for_new_project(sample_project_params)
    if project_data.nil?
      puts('Master project not found.')
      logger.error('Master project not found.')
      exit(1)
    end

    # create sample project
    ActiveRecord::Base.transaction do
      helper.create_sample_project(project_data, sample_data_path)
    end
  end

  puts 'inserting sample source scale data...'

  # connect to IPF DB
  helper.connect(config['ipf_database'].merge(:adapter => 'postgresql')) do
    # create source scale data
    ActiveRecord::Base.connection.execute("SET search_path TO #{pmdata_schema}")
    ActiveRecord::Base.transaction do
      helper.insert_source_data(sample_data_path)
    end
  end

  puts 'executing project platform collect...'

  # execute pf batch
  batch_result = helper.execute_pf_batch(config['config']['ipf_batch_path'])
  if batch_result != 0
    logger.error("Executing PF data failed. rtn_cd = #{batch_result}")
    puts "Executing PF data failed. rtn_cd = #{batch_result}"
    exit(1)
  end

  puts 'executing graph data collect...'

  # execute graph batch
  batch_result = helper.execute_graph_batch(config['config']['ipf_batch_path'])
  if batch_result != 0
    logger.error("Executing graph data failed. rtn_cd = #{batch_result}")
    puts "Executing graph data failed. rtn_cd = #{batch_result}"
    exit(1)
  end

  puts 'complete create sample project'
rescue
  raise
ensure
  lock_object.unlock
end

exit(0)
