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
require File.expand_path("../ipf_repository_utils",__FILE__)
require File.expand_path("../postgres_connector",__FILE__)

#
#= Repository Environment
#
#  This is the environment class for Create and Delete repository script.
#
class IpfRepositoryEnv

  include IpfRepositoryUtils

  # scm name
  SCM_SVN = "Subversion"
  SCM_Git = "Git"

  # project id
  attr_accessor :project_id
  
  # project id
  attr_accessor :project_identifier

  # Types of SCM
  attr_accessor :type
  
  # repository directory
  attr_accessor :repository_out_dir
  
  # repository directory for project
  attr_accessor :repository_proj_dir
  attr_accessor :debugtest

  # repository temp directory for project
  attr_accessor :repository_proj_dir_temp

  # svnadmin path
  attr_accessor :svnadmin_path

  # git path
  attr_accessor :git_path
  
  # Redmine DB settings
  attr_accessor :redmine_db_host
  attr_accessor :redmine_db_port
  attr_accessor :redmine_db_database
  attr_accessor :redmine_db_username
  attr_accessor :redmine_db_password
  
  # Batch path
  attr_accessor :batch_path
  
  #
  #=== env initialize
  #
  def initialize(project_identifier, type)
    @project_identifier = project_identifier
    @type = type

    # setting file read
    settings = read_repository_settings

    @repository_out_dir = settings["IpfRepository"]["repository_out_dir"]
    @svnadmin_path = settings["IpfRepository"]["svnadmin_path"]
    @git_path = settings["IpfRepository"]["git_path"]
    
    @redmine_db_host = settings["IpfRepository"]["Redmine"]["DB"]["host"] 
    @redmine_db_port = settings["IpfRepository"]["Redmine"]["DB"]["port"] 
    @redmine_db_database = settings["IpfRepository"]["Redmine"]["DB"]["database"]
    @redmine_db_username = settings["IpfRepository"]["Redmine"]["DB"]["username"]
    @redmine_db_password = settings["IpfRepository"]["Redmine"]["DB"]["password"]
    
    if SCM_SVN == type then
      @batch_path = settings["IpfRepository"]["CommitHook"]["Subversion"]["batch_path"]
    else
      @batch_path = settings["IpfRepository"]["CommitHook"]["Git"]["batch_path"]
    end
    
    @project_id = get_project_id
    
    @repository_proj_dir = ""
    @repository_proj_dir_temp = ""
    @repository_proj_dir = File.join(@repository_out_dir, @project_id) if @project_id
    @repository_proj_dir_temp = @repository_proj_dir + "_" + Time.now.strftime("%Y%m%d_%H%M%S") if @repository_proj_dir

  end
  
  #
  #===Repository settings file load
  #
  def read_repository_settings
    YAML.load_file(File.expand_path("../../config/repository_settings.yml",__FILE__))
  end  
  
  #
  #===Create repository temp directory  
  #
  def create_repository_temp_dir
    # create repository temp_directory
    FileUtils.makedirs(@repository_proj_dir_temp)
  end
  
  #
  #===To rename repository directory to temp directory 
  #
  def rename_repository_dir
    File.rename(@repository_proj_dir_temp,@repository_proj_dir)
  end
  
  #
  #= repositories data exist check
  #  
  def repositories_exist?
    result = false
    sql = 'select id from repositories where project_id = ' + @project_id
    repositories = exec_select_sql(sql)
    repositories.each do |proj|
      result = true
      break
    end
    result
  end
  
  #
  #= get_project_id
  #  
  def get_project_id
    result = ""
    sql = 'select id from projects where identifier = ' + '\'' + @project_identifier + '\''
    begin
      project = exec_select_sql(sql)
      project.each do |proj|
        result = proj['id']
        break
      end
    rescue
      # nothing      
    end
    result
  end
  
  #
  #= project_id exist check
  #  
  def project_id_exist?
    @project_id ? (@project_id != "" ? true : false) : false
  end
  
  #
  #= execute select sql
  #  
  def exec_select_sql(sql)
    PostgresConnector.connect(
      @redmine_db_host,
      @redmine_db_port,
      @redmine_db_database,
      @redmine_db_username,
      @redmine_db_password) do |dbobj|
      result = dbobj.query_sql(sql)
    end
  end
  
end