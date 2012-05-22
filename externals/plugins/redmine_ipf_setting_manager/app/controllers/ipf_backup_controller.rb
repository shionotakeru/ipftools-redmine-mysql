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

require 'ipf_setting_manager_utils'
include IpfSettingManagerUtils

#
#= Backup Controller
#
class IpfBackupController < ApplicationController
  unloadable
  layout 'admin'
  
  before_filter :require_admin

  #===display initialize
  #  
  def index
    get_backup_list
  end
  
  #===get backup list  
  #
  def get_backup_list
    @backups = IpfBackup.find(:all, :order => "backup_date") 
  end

  #===run backup
  #
  def backup

    # create backup command 
    backup_cmd = "ruby " << File.join(Setting.plugin_redmine_ipf_setting_manager['ipf_backup_script'],'ipf_backup.rb') << " " << params[:target]

    # execute backup
    system "#{backup_cmd}"
 
    # Results returned in JSON format
    if 0 == $? then
      result_code = 0
      message = nil
    else
      result_code = $?.exitstatus
      message = get_error_message(result_code)
    end
    send_response_json(result_code, message)    

  end
  
  #===Download file check
  #  Check the backup files exist.
  #
  def download_check
    begin
      backup = IpfBackup.find(params[:id])
    rescue
      send_response_json(10, get_error_message(10))
      return
    end

    # Check if the file exists
    begin
      unless File.exist?(backup.file_path)
        send_response_json(10, get_error_message(10))
      end
    rescue
        send_response_json(-1, get_error_message(-1))      
    end
    
    send_response_json(0)
  end

  
  #===Download backup file by ID
  #
  def download
    backup = IpfBackup.find(params[:id])

    # download
    send_file(backup.file_path)
  end
  
  #===Delete backup file by ID
  #
  def delete
    begin
      backup = IpfBackup.find(params[:id])
    rescue
      # If no data, and successfully removed already determined that
      send_response_json(0)
      return
    end
    
    begin
      if File.exist?(backup.file_path)
        FileUtils.rm(backup.file_path)
      else
        # nothing. If backup file doesn't exist, delete record only
      end
      backup.destroy
      send_response_json(0)
    rescue
      send_response_json(-1, get_error_message(-1))  
    end
  end
 
end