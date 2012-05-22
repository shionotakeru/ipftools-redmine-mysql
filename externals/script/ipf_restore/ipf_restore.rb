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
#= Restore script
#
#== Argument
# ARGV[0] : backup file path
#

$:.unshift(File.dirname(File.expand_path(__FILE__)))
require 'fileutils'
require 'logger'
require 'lib/ipf_restore_env'
require 'lib/ipf_restore_utils'
require 'lib/ipf_backup_archive'
require 'lib/lockfile'
require 'lib/postgres_connector'

module IpfRestoreModule

  #
  #= Error handling method
  #
  def exit_error(message, error = nil)
    begin
      logger = Logger.new(File.expand_path("../log/ipf_restore.log", __FILE__))
      logger.level = Logger::ERROR
      logger.datetime_format = "%Y/%m/%d %H:%M:%S"

      # output log
      logger.error(message)
      logger.error(error) if error

      # output message
      puts message
      puts error if error
    rescue
      # nothing
      raise
    end

    # error exit
    exit(1)
  end
end

include IpfRestoreModule
include IpfRestoreUtils

lock_object = nil
restore_env = nil

### Finalizer ########################################################################
at_exit do
  lock_object.unlock unless lock_object.nil?
  unless restore_env.nil?
    if File.directory?(restore_env.restore_temp_dir)
      FileUtils.rm_r(restore_env.restore_temp_dir)
    end
  end
end

### Argument check ###################################################################
unless ARGV.size == 1
  exit_error('invalid argument.')
end
backup_file_path = ARGV[0]

### lockfile check and create ########################################################
begin
  lockfile_path = File.join(Dir.tmpdir, 'ipf_restore.lock')
  if File.exist?(lockfile_path)
    exit_error('Another process executing.')
  end

  # create lock object
  lock_object = Lockfile.new(lockfile_path)

  # lock
  unless lock_object.lock
    exit_error('Failed to lock.')
  end
rescue => err
  exit_error('Failed to create lock file.', err)
end

### Initializing process #############################################################
# check backup file exist
unless File.exist?(backup_file_path)
  exit_error("Backup file [#{backup_file_path}] not found.")
end

# Env create
begin
  restore_env = IpfRestoreEnv.new
rescue => err
  exit_error('Failed to create processing environment..', err)
end

### Extract backup file ##############################################################
archive = IpfBackupArchive.new(backup_file_path)
begin
  archive.extract_to(restore_env.restore_temp_dir)

  unless archive.valid_archive?
    exit_error("[#{backup_file_path}] is invalid archive.")
  end
rescue => err
  exit_error('Failed to extract backup archive.', err)
end

### Restore Redmine DB ###############################################################
begin
  # find 'psql' command
  psql = IpfRestoreUtils::find_command("psql")
  if psql.nil?
    exit_error('psql command not found.')
  end

  # create psql command line
  restore_command = sprintf("\"#{psql}\" -h %s -p %s -U %s -d %s -f \"%s\"",
                            restore_env.redmine_db_host,
                            restore_env.redmine_db_port,
                            restore_env.redmine_db_username,
                            restore_env.redmine_db_database,
                            archive.redmine_db_dump)
  # set psql password to environment variable
  ENV['PGPASSWORD'] = restore_env.redmine_db_password

  # execute command
  system restore_command
  if $? != 0
    exit_error("Failed to restore redmine DB. [ret=#{$?.exitstatus}]")
  end

rescue => err
  exit_error('Failed to restore Redmine DB.', err)
end

### Restore Redmine attachment files #################################################
begin
  # remove old attarchment dir
  FileUtils.rm_r(restore_env.redmine_append_path) if File.exist?(restore_env.redmine_append_path)

  # move backup files to attachment dir
  FileUtils.cp_r(archive.redmine_appended_dir, restore_env.redmine_append_path)

rescue => err
  exit_error('Failed to restore Redmine attachment files.', err)
end

### Restore IPF DB ###################################################################
begin
  if archive.archived_all?
    # find 'psql' command
    psql = IpfRestoreUtils::find_command("psql")
    if psql.nil?
      exit_error('psql command not found.')
    end

    # create psql command line
    restore_command = sprintf("\"#{psql}\" -h %s -p %s -U %s -d %s -f \"%s\"",
                              restore_env.ipf_db_host,
                              restore_env.ipf_db_port,
                              restore_env.ipf_db_username,
                              restore_env.ipf_db_database,
                              archive.ipf_db_dump)
    # set psql password to environment variable
    ENV['PGPASSWORD'] = restore_env.ipf_db_password

    # execute command
    system restore_command
    if $? != 0
      exit_error("Failed to restore IPF DB. [ret=#{$?.exitstatus}]")
    end
  end
rescue => err
  exit_error('Failed to restore IPF DB.', err)
end

### Restore GIT repository ###########################################################
begin
  # enumerate project id
  git_projects = archive.get_git_projects
  git_projects.each do |project_id|
    git_archive = File.join(archive.git_repos_dir, project_id)

    repository_dir = nil

    # get repository directory from redmine DB
    PostgresConnector.connect(
      restore_env.redmine_db_host,
      restore_env.redmine_db_port,
      restore_env.redmine_db_database,
      restore_env.redmine_db_username,
      restore_env.redmine_db_password) do |conn|

      repos_to = conn.query_sql("SELECT url FROM repositories WHERE project_id=#{project_id}")
      repository_dir = repos_to[0]["url"] if repos_to.num_tuples > 0
    end

    unless repository_dir.nil?
      if File.exist?(repository_dir)
        # remove old repository if exists.
        FileUtils.rm_r(repository_dir)
      else
        # create repository directory if not exists.
        repository_base = File.dirname(repository_dir)
        unless File.exist?(repository_base)
          FileUtils.mkdir_p(repository_base)
        end
      end

      # move archived repository to project repository
      FileUtils.cp_r(git_archive, repository_dir)
    end
  end
rescue => err
  exit_error('Failed to restore GIT repository.', err)
end

### Restore SVN repository ###########################################################
begin
  # enumerate project id
  svn_projects = archive.get_svn_projects
  svn_projects.each do |project_id|
    svn_archive = File.join(archive.svn_repos_dir, project_id)

    repository_dir = nil

    # get repository directory from redmine DB
    PostgresConnector.connect(
      restore_env.redmine_db_host,
      restore_env.redmine_db_port,
      restore_env.redmine_db_database,
      restore_env.redmine_db_username,
      restore_env.redmine_db_password ) do |conn|

      repos_to = conn.query_sql("SELECT url FROM repositories WHERE project_id=#{project_id}")
      repository_dir = convert_repository_path(repos_to[0]["url"]) if repos_to.num_tuples > 0
    end

    unless repository_dir.nil?
      if File.exist?(repository_dir)
        # remove old repository if exists.
        FileUtils.rm_r(repository_dir)
      else
        # create repository directory if not exists.
        repository_base = File.dirname(repository_dir)
        unless File.exist?(repository_base)
          FileUtils.mkdir_p(repository_base)
        end
      end

      # move archived repository to project repository
      FileUtils.cp_r(svn_archive, repository_dir)
    end

  end
rescue => err
  exit_error('Failed to restore SVN repository.', err)
end

exit(0)
