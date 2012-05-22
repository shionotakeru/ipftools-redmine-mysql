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

require 'yaml'
require 'fileutils'

#
#= Backup Environment
#
#  This is the environment class for backup.
#
class IpfBackupEnv

  # backup target
  attr_accessor :backup_target

  # script execute datetime
  attr_accessor :exec_datetime

  # zip file name
  attr_accessor :zip_file_name

  # postgres env 
  attr_accessor :pgpassword
  
  # directory
  attr_accessor :backup_out_dir
  
  # pg_dump path
  attr_accessor :pg_dump_path
  
  # Redmine DB settings
  attr_accessor :redmine_db_host
  attr_accessor :redmine_db_port
  attr_accessor :redmine_db_database
  attr_accessor :redmine_db_username
  attr_accessor :redmine_db_password
  
  # Redmine appended-file path
  attr_accessor :redmine_appended_path
  
  # IPF DB settings
  attr_accessor :ipf_db_host
  attr_accessor :ipf_db_port
  attr_accessor :ipf_db_database
  attr_accessor :ipf_db_username
  attr_accessor :ipf_db_password

  # backup file or directory name
  attr_accessor :bkname_home
  attr_accessor :bkname_redmine_db
  attr_accessor :bkname_ipf_db
  
  # backup directory path
  attr_accessor :bkdir_home
  attr_accessor :bkdir_redmine_db
  attr_accessor :bkdir_redmine_appended
  attr_accessor :bkdir_ipf_db
  attr_accessor :bkdir_svn
  attr_accessor :bkdir_git
  
  
  #
  #=== env initialize
  #
  def initialize(target)
    @backup_target = target
    @exec_datetime = Time.now.strftime("%Y%m%d_%H%M%S")
    if "0" == @backup_target then 
      @zip_file_name = "ipf_backup_ALL_" + @exec_datetime + ".zip"
    else
      @zip_file_name = "ipf_backup_" + @exec_datetime + ".zip"
    end
    @pgpassword = 'PGPASSWORD'
    
    # setting file read
    settings = read_backup_settings
    
    @backup_out_dir = settings["IpfBackup"]["backup_out_dir"]
    @pg_dump_path = settings["IpfBackup"]["pg_dump_path"]
    
    @redmine_db_host = settings["IpfBackup"]["Redmine"]["DB"]["host"] 
    @redmine_db_port = settings["IpfBackup"]["Redmine"]["DB"]["port"] 
    @redmine_db_database = settings["IpfBackup"]["Redmine"]["DB"]["database"]
    @redmine_db_username = settings["IpfBackup"]["Redmine"]["DB"]["username"]
    @redmine_db_password = settings["IpfBackup"]["Redmine"]["DB"]["password"]
    @redmine_appended_path = settings["IpfBackup"]["Redmine"]["Appended"]["path"] 
     
    @ipf_db_host = settings["IpfBackup"]["IPF_DB"]["host"]
    @ipf_db_port = settings["IpfBackup"]["IPF_DB"]["port"]
    @ipf_db_database = settings["IpfBackup"]["IPF_DB"]["database"]
    @ipf_db_username = settings["IpfBackup"]["IPF_DB"]["username"]
    @ipf_db_password = settings["IpfBackup"]["IPF_DB"]["password"]
    
    # bk file or directory name
    @bkname_home = "ipf_backup"
    @bkname_redmine_db = "redminedb.dump"
    @bkname_ipf_db = "ipfdb.dump"
    
    # backup directory path
    @bkdir_home = File.join(@backup_out_dir,@bkname_home)
    @bkdir_redmine_db = File.join(@bkdir_home,"redmine_db")
    
    @bkdir_redmine_appended = File.join(@bkdir_home,"redmine_appended")
    @bkdir_ipf_db = File.join(@bkdir_home,"ipf_db") 
    @bkdir_svn = File.join(@bkdir_home,"svn")
    @bkdir_git = File.join(@bkdir_home,"git")
    
    # create backup directory
    create_backup_dir(@backup_target)
  end
  
  #
  #===Backup settings file load
  #
  def read_backup_settings
    YAML.load_file(File.expand_path("../../config/backup_settings.yml",__FILE__))
  end  
  
  #
  #===backup directory create 
  #
  def create_backup_dir(target)
   
    # delete directory
    begin
      delete_backup_dir
    rescue
      # nothing
    end
    
    # create backup directory
    FileUtils.makedirs(@bkdir_home)
    FileUtils.mkdir(@bkdir_redmine_db)
    FileUtils.mkdir(@bkdir_redmine_appended)
    FileUtils.mkdir(@bkdir_svn)
    FileUtils.mkdir(@bkdir_git)
    FileUtils.mkdir(@bkdir_ipf_db) if "0" == target
  end

  #
  #===delete backup directory
  #
  def delete_backup_dir
    FileUtils.rm_r(@bkdir_home) if File.directory?(@bkdir_home)
  end
  
end