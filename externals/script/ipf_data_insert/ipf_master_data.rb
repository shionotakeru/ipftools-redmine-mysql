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
#=Create IPF Master Data
#

$:.unshift(File.dirname(File.expand_path(__FILE__)))
require 'lib/postgres_connector'
require 'lib/lockfile'
require 'tmpdir'
require 'yaml'
require 'pp'

# read configuration
config = YAML.load(File.open(File.expand_path('../config/ipf_data_insert_settings.yml', __FILE__)))
database_config = config['database']
master_data_path = config['config']['master_data_path']

# check lock file
lock_file = File.join(Dir.tmpdir, 'ipf_data_insert.lock')
if File.exist?(lock_file)
  puts 'Another process executing.'
  exit(1)
end

# create lock object
lock_object = Lockfile.new(lock_file)

begin
  unless lock_object.lock
    puts 'Lock failed.'
    exit(1)
  end

  # connect to Redmine DB (PostgreSQL)
  PostgresConnector.connect(
    database_config['host'],
    database_config['port'],
    database_config['database'],
    database_config['username'],
    database_config['password']) do |dbobj|

    dbobj.transaction do

      # create master data from CSV file.
      # CSV file is in master data path.
      Dir.glob(File.join(master_data_path, 'SampleProject_Data_*.csv')) do |csvfile|
        table_name = File.basename(csvfile, ".csv").gsub(/^SampleProject_Data_(\w+)$/, '\\1')

        options = {:truncate => true}

        case table_name.downcase
          when 'custom_fields_trackers'
            options.merge!(:ignore_id => true)
          else
        end

        dbobj.copy(table_name, csvfile, options)
      end

      # set admin's language to "ja"
      dbobj.exec_sql("UPDATE users SET language = 'ja' WHERE id = 1")
    end

  end
rescue => err
  pp err
ensure
  lock_object.unlock
end
