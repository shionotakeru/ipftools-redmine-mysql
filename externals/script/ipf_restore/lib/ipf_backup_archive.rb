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

require 'rubygems'
require 'zipruby'
require 'fileutils'

#
#=Backup archive file container class
#
class IpfBackupArchive
  attr_reader :zip_file_path

  attr_reader :extract_files
  attr_reader :comment

  attr_reader :redmine_db_dump
  attr_reader :redmine_appended_dir
  attr_reader :ipf_db_dump

  attr_reader :git_repos_dir
  attr_reader :svn_repos_dir

  def initialize(zip_file_name)
    @zip_file_path = zip_file_name
  end

  #
  #===Extract zip archive to output_dir
  #
  def extract_to(output_dir)
    if File.exist?(output_dir)
      unless File.directory?(output_dir)
        raise "[#{output_dir}] is not directory."
      end
    else
      # create output directory
      FileUtils.mkdir_p(output_dir)
    end

    Zip::Archive.open(@zip_file_path) do |ar|
      @comment = ar.comment
      @extract_files = []
      @extract_directory = output_dir

      ar.each do |zf|
        fullpath = File.join(output_dir, zf.name)
        if zf.directory?
          FileUtils.mkdir_p(fullpath)
          @extract_files.push(fullpath)
        else
          dirname = File.dirname(fullpath)
          FileUtils.mkdir_p(dirname) unless File.exist?(dirname)

          open(fullpath, "wb") do |f|
            f << zf.read
          end
          @extract_files.push(fullpath)
        end
      end
    end

    @redmine_db_dump = File.join(@extract_directory, 'ipf_backup', 'redmine_db', 'redminedb.dump')
    @ipf_db_dump = File.join(@extract_directory, 'ipf_backup', 'ipf_db', 'ipfdb.dump')
    @git_repos_dir = File.join(@extract_directory, 'ipf_backup', 'git')
    @svn_repos_dir = File.join(@extract_directory, 'ipf_backup', 'svn')
    @redmine_appended_dir = File.join(@extract_directory, 'ipf_backup', 'redmine_appended', 'files')
  end

  #
  #===check archive
  #
  def valid_archive?
    # check git directory
    unless File.exist?(@git_repos_dir)
      return false
    end

    # check svn directory
    unless File.exist?(@svn_repos_dir)
      return false
    end

    # check redmine db dump
    unless File.exist?(@redmine_db_dump)
      return false
    end

    if archived_all?
      # check IPF db dump
      unless File.exist?(@ipf_db_dump)
        return false
      end
    end

    # check redmine attachment files
    unless File.exist?(@redmine_appended_dir)
      return false
    end

    # check ok
    true
  end

  #
  #=get project id list which is using GIT
  #
  def get_git_projects
    project_id = []
    Dir.foreach(@git_repos_dir) do |f|
      if (f != ".") && (f != "..")
        path = File.join(@git_repos_dir, f)
        if File.directory?(path)
          project_id.push(f)
        end
      end
    end
    project_id
  end

  #
  #=get project id list which is using SVN
  #
  def get_svn_projects
    project_id = []
    Dir.foreach(@svn_repos_dir) do |f|
      if (f != ".") && (f != "..")
        path = File.join(@svn_repos_dir, f)
        if File.directory?(path)
          project_id.push(f)
        end
      end
    end
    project_id
  end

  def archived_all?
    @comment == "0"
  end

  def archived_without_ipfdb?
    @comment == "1"
  end
end

