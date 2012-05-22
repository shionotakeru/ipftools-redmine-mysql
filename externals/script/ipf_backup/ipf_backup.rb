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
#= Backup script
#
#  This is the backup processing.
#
#  backup target is as follows.
#  
#*  Redmine DB
#*  IPF DB
#*  Redmine Appended files
#*  SCM Repository
#     Subversion
#     Git
#
#== Argument
#  ARGV[0] : backup target
#           0 : IPF all  
#           1 : non-IPFDB
#
#
require 'logger'
require 'tmpdir'
require File.expand_path("../lib/ipf_backup_env",__FILE__)
require File.expand_path("../lib/ipf_backup_utils",__FILE__)
require File.expand_path("../lib/lockfile",__FILE__)
require File.expand_path("../lib/postgres_connector",__FILE__)

#
#= backup script module
#
module IpfBackupModule
    
  #
  #= Error handling method
  #  
  def exit_error(exit_code, message, error = nil)
    
    begin
      # logger create
      logger = Logger.new(File.expand_path("../log/ipf_backup.log",__FILE__))
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

end


# module include
include IpfBackupModule
include IpfBackupUtils

lock_object = nil
backup_env = nil

### Finalizer ########################################################################
at_exit do
  lock_object.unlock unless lock_object.nil?
  if backup_env then
    if File.directory?(backup_env.bkdir_home) then
        FileUtils.rm_r(backup_env.bkdir_home) 
    end
  end
end

### Argument check ###################################################################

unless ARGV.size == 1 && (ARGV[0] == "0" || ARGV[0] == "1") 
  exit_error(-1, 'invalid argument.')
end

### lockfile check and create ########################################################
begin
  lock_file = File.join(Dir.tmpdir, 'ipf_backup.lock')
  if File.exist?(lock_file)
    exit_error(11, 'Another process executing.')
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
  backup_env = IpfBackupEnv.new(ARGV[0])
rescue => err
  exit_error(-1, 'Failed to create processing environment..', err)
end

### Redmine appended files backup ########################################################

begin
  FileUtils.cp_r(backup_env.redmine_appended_path, backup_env.bkdir_redmine_appended)
rescue => err
  exit_error(12, "Failed to copy Redmine-Appended-files.", err)
end

### Redmine DB backup ################################################################

begin
  ENV[backup_env.pgpassword] = backup_env.redmine_db_password

  # create pgdump command
  command = get_pgdump_cmd(
                            backup_env.pg_dump_path,
                            backup_env.redmine_db_host,
                            backup_env.redmine_db_port, 
                            backup_env.redmine_db_username,
                            backup_env.redmine_db_database,
                            File.join(backup_env.bkdir_redmine_db, backup_env.bkname_redmine_db)
                           )
  
  # execute pgdump command
  system "#{command}"
  if 0 != $? then
    raise "pg_dump command failed."
  end

  ENV.delete(backup_env.pgpassword)
rescue => err
  exit_error(13, "Failed to backup Redmine DB.", err)
end

### IPF DB backup ####################################################################

if "0" == backup_env.backup_target then
  begin
    ENV[backup_env.pgpassword] = backup_env.ipf_db_password
  
    # create pgdump command
    command = get_pgdump_cmd(
                              backup_env.pg_dump_path,
                              backup_env.ipf_db_host,
                              backup_env.ipf_db_port,
                              backup_env.ipf_db_username,
                              backup_env.ipf_db_database,
                              File.join(backup_env.bkdir_ipf_db, backup_env.bkname_ipf_db)
                             )
  
    # execute pgdump command
    system "#{command}"
    if 0 != $? then
      raise "pg_dump command failed."
    end

    ENV.delete(backup_env.pgpassword)
  rescue => err
    exit_error(14, "Failed to backup IPF DB.", err)
  end
end

### repository backup ################################################################

begin
  # connect to Redmine DB
  PostgresConnector.connect(
    backup_env.redmine_db_host,
    backup_env.redmine_db_port,
    backup_env.redmine_db_database,
    backup_env.redmine_db_username,
    backup_env.redmine_db_password) do |dbobj|

    sql = "select project_id, url, type from repositories"
    repository = dbobj.query_sql(sql)

    # backup repository
    repository.each do |repos|
      repos_p_id = repos['project_id']
      repos_url  = convert_repository_path(repos['url'])
      repos_type = repos['type']
      if repos_p_id && repos_url then
        case repos_type
          when 'Subversion' then
              repos_dir = FileUtils.mkdir(File.join(backup_env.bkdir_svn,repos_p_id))
          when 'Git' then
              repos_dir = FileUtils.mkdir(File.join(backup_env.bkdir_git,repos_p_id))
        end  
        
        # copy to repository directory
        begin
          if File.directory?(repos_url)
            FileUtils.cp_r(Dir.glob(File.join(repos_url,"*")), repos_dir[0])  
          else
            raise
          end
        rescue
          # Failure to copy, delete the directory for project. No errors.
          FileUtils.rm_r(repos_dir[0])
        end
      end
    end

  end
rescue => err
  exit_error(15, "Failed to copy Repository files", err)
end


### ZIP compression ##################################################################
begin
  # make Zip file
  make_zip(backup_env.bkname_home, backup_env.zip_file_name, backup_env.backup_out_dir)
  # add comment
  add_zip_comment(File.join(backup_env.backup_out_dir,backup_env.zip_file_name),backup_env.backup_target)
  # delete backup directory
  backup_env.delete_backup_dir
rescue => err
  exit_error(16, "Failed to ZIP compression", err)
end

### Insert backup data into Redmine ###################################################
begin
  PostgresConnector.connect(
    backup_env.redmine_db_host,
    backup_env.redmine_db_port,
    backup_env.redmine_db_database,
    backup_env.redmine_db_username,
    backup_env.redmine_db_password) do |dbobj|
    dbobj.transaction do
      sql = "insert into ipf_backups (id,target,backup_date,file_path) values (nextval('ipf_backups_id_seq') ," + backup_env.backup_target + ",'" + backup_env.exec_datetime + "','" + File.join(backup_env.backup_out_dir,backup_env.zip_file_name) + "')"
      dbobj.exec_sql(sql)
    end
  end  
rescue => err
  exit_error(17, "Failed to insert backup data", err)
end
