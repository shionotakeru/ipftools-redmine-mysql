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
#= Create repository script
#
#  This is the process of creation of the repository.
#
#== Argument
#  ARGV[0] : project_identifier
#  ARGV[1] : Types of SCM : "Subversion" or "Git"
#               
#
#
require 'logger'
require 'tmpdir'
require File.expand_path("../lib/ipf_repository_env",__FILE__)
require File.expand_path("../lib/ipf_repository_utils",__FILE__)
require File.expand_path("../lib/lockfile",__FILE__)
require File.expand_path("../lib/commit_hooks",__FILE__)
require File.expand_path("../lib/postgres_connector",__FILE__)


#
#= Create repository script module
#
module IpfRepositoryCreateModule
    
  #
  #= Error handling method
  #  
  def exit_error(exit_code, message, error = nil)

    begin
      # logger create
      logger = Logger.new(File.expand_path("../log/ipf_repository_create.log",__FILE__))
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
  
  #===Association to get SQL to repository
  #
  def get_association_sql(project_id, url, type)
    sql = 'insert into repositories' +
          ' (id, project_id, url, type )' +
          ' values (' +
          ' nextval(\'repositories_id_seq\')' + # id
          ',' + project_id + # project_id
          ',' + '\'' + convert_url(url, type) + '\'' + # url
          ',' + '\'' + type + '\'' +  # type
          ')'
  end

end


# module include
include IpfRepositoryCreateModule
include IpfRepositoryUtils

lock_object = nil
repository_env = nil

### Finalizer ########################################################################
at_exit do
  lock_object.unlock unless lock_object.nil?
  if repository_env then
    if File.directory?(repository_env.repository_proj_dir_temp) then
        FileUtils.rm_r(repository_env.repository_proj_dir_temp) 
    end
  end
end

### Argument check ###################################################################
arg_err = false
arg_err = true unless ARGV.size == 2 
arg_err = true unless ARGV[1] == IpfRepositoryEnv::SCM_SVN || ARGV[1] == IpfRepositoryEnv::SCM_Git

exit_error(-1, 'invalid argument.') if arg_err

### lockfile check and create ########################################################
begin
  lock_file = File.join(Dir.tmpdir, 'ipf_repository_' + ARGV[0] + '.lock')
  if File.exist?(lock_file)
    exit_error(20, 'Another process executing.')
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
  repository_env = IpfRepositoryEnv.new(ARGV[0],ARGV[1])
rescue => err
  exit_error(-1, 'Failed to create processing environment.', err)
end

### project check ####################################################################
begin 
  exit_error(21, 'Project not found.') unless repository_env.project_id_exist?
rescue => err
  exit_error(-1, 'Failed to check existence of project.', err)
end

### project repository check #########################################################
begin
  # repository configuration check
  exit_error(22, 'This project has already been configured repositories.') if repository_env.repositories_exist? 
  # repository check
  exit_error(23, 'This project repository already exists.') if File.directory?(repository_env.repository_proj_dir)  
rescue => err
  exit_error(-1, 'Failed to check project repository.', err)
end

### create repository ################################################################
begin
  #create temp directory
  repository_env.create_repository_temp_dir

  #home path
  home_path = Dir::pwd

  #create command
  case repository_env.type
    when IpfRepositoryEnv::SCM_SVN
      command = get_svnrepos_create_cmd(repository_env.svnadmin_path, repository_env.repository_proj_dir_temp)
    when IpfRepositoryEnv::SCM_Git
      command = get_gitrepos_create_cmd(repository_env.git_path, repository_env.repository_proj_dir_temp)
  end

  #execute command
  if command 
    command.each do |cmd|
      system "#{cmd}"
      if 0 != $? then
        raise "repository-create command failed."
      end
    end
  else
    raise "create repository-create command failed."
  end

  # add commit hook
  hooksobj = CommitHooks.new( repository_env.type, 
                              repository_env.repository_proj_dir_temp,
                              repository_env.project_identifier,
                              repository_env.batch_path
                              )
  hooksobj.create 
rescue => err
  exit_error(24, "Failed to create repository", err)
end

### Insert repository data into Redmine ###############################################
begin
  PostgresConnector.connect(
    repository_env.redmine_db_host,
    repository_env.redmine_db_port,
    repository_env.redmine_db_database,
    repository_env.redmine_db_username,
    repository_env.redmine_db_password) do |dbobj|
    dbobj.transaction do
      sql = get_association_sql(repository_env.project_id, repository_env.repository_proj_dir, repository_env.type)
      dbobj.exec_sql(sql)
    end
  end    
rescue => err
  exit_error(25, "Failed to insert into redmine repository data ", err)
end

### Repository directory rename ######################################################## 
begin
  repository_env.rename_repository_dir
rescue => err
  exit_error(-1, "Failed to rename of repository directory", err)
end
