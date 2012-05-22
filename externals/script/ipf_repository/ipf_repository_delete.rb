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
#= Delete repository script
#
#  This is the process of deletion of the repository.
#
#== Argument
#  ARGV[0] : project_identifier
#
#
require 'logger'
require 'tmpdir'
require File.expand_path("../lib/ipf_repository_env",__FILE__)
require File.expand_path("../lib/ipf_repository_utils",__FILE__)
require File.expand_path("../lib/lockfile",__FILE__)
require File.expand_path("../lib/postgres_connector",__FILE__)


#
#= Delete repository script module
#
module IpfRepositoryDeleteModule
    
  #
  #= Error handling method
  #  
  def exit_error(exit_code, message, error = nil)

    begin
      # logger create
      logger = Logger.new(File.expand_path("../log/ipf_repository_delete.log",__FILE__))
      logger.datetime_format = "%Y/%m/%d %H:%M:%S"
      logger.formatter = Logger::Formatter.new
      
      # output log
      logger.error(message)
      logger.error(error) if error
      
      # output message
      puts message
      puts error if error
    rescue
      raise
    end
    
    # error exit
    exit(exit_code)
  end
  
  #===get SQL find repository data 
  #
  def get_find_repository_sql(project_id)
    sql = 'select url from repositories where project_id = ' + project_id
  end
  
  #===get SQL delete repository data 
  #
  def get_delete_repository_sql(project_id)
    sql = 'delete from repositories where project_id = ' + project_id
  end

end


# module include
include IpfRepositoryDeleteModule
include IpfRepositoryUtils

lock_object = nil

### Finalizer ########################################################################
at_exit do
  lock_object.unlock unless lock_object.nil?
end

### Argument check ###################################################################
arg_err = false
arg_err = true unless ARGV.size == 1 

exit_error(-1, 'invalid argument.') if arg_err

### lockfile check and create ########################################################
begin
  lock_file = File.join(Dir.tmpdir, 'ipf_repository_' + ARGV[0] + '.lock')
  if File.exist?(lock_file)
    exit_error(30, 'Another process executing.')
  end
  
  # create lock object
  lock_object = Lockfile.new(lock_file)
  
  # lock
  unless lock_object.lock
    exit_error(-1, 'Failed to lock.')
  end
rescue => err
    exit_error(-1, 'Failed to create lock file.', err)
end

### Initializing process ############################################################# 
begin
  repository_env = IpfRepositoryEnv.new(ARGV[0],nil)
rescue => err
  exit_error(-1, 'Failed to create processing environment.', err)
end

### project check #################################################################### 
begin
  exit_error(31, 'Project not found.') unless repository_env.project_id_exist?
rescue => err
  exit_error(-1, 'Failed to check existence of project.', err)
end
### project repository check #########################################################
begin
  # repository configuration check
  exit_error(32, 'This project not configured repositories.') unless repository_env.repositories_exist? 
  # repository check
  exit_error(33, 'This project repository is not exist.') unless File.directory?(repository_env.repository_proj_dir)
rescue => err
  exit_error(-1, 'Failed to check project repository.', err)
end

### delete repository ################################################################
begin
  PostgresConnector.connect(
    repository_env.redmine_db_host,
    repository_env.redmine_db_port,
    repository_env.redmine_db_database,
    repository_env.redmine_db_username,
    repository_env.redmine_db_password) do |dbobj|
    
    dbobj.transaction do

      # find repository data
      sql = get_find_repository_sql(repository_env.project_id)
      repository = dbobj.query_sql(sql)
      
      repository.each do |repos|
        repos_url = convert_repository_path(repos['url'])
        # delete repository data
        sql = get_delete_repository_sql(repository_env.project_id)
        dbobj.exec_sql(sql)
        # delete repository directory
        FileUtils.rm_r(repos_url)
      end

    end
  end 
rescue => err
  exit_error(34, "Failed to delete repository.", err)
end
