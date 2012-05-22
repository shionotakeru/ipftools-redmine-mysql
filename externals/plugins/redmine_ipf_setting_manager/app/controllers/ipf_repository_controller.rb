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
class IpfRepositoryController < ApplicationController
  unloadable
  layout 'admin'
  
  before_filter :require_admin
  
  # action_name
  @@ACTION_CREATE = "create"
  @@ACTION_DELETE = "delete"

  #===display initialize
  #  
  def index
   arc = ARCondition.new("status = 1")
   @ipf_repos_project = Project.find(:all, :order => 'lft', :conditions => arc.conditions)
  end
  
  #===repository create
  #  
  def create
    execute(@@ACTION_CREATE)
  end
  
  #===repository delete
  #  
  def delete
    execute(@@ACTION_DELETE)
  end

  private

  #===execute action
  #  
  def execute(action_name)
    # create command
    cmd = create_command(action_name, params[:project_identifier])

    # command exec
    system "#{cmd}"
    
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

  #===create command 
  #  
  def create_command(action_name, project_identifier)
     command = "ruby " + File.join(Setting.plugin_redmine_ipf_setting_manager['ipf_repository_script'],('ipf_repository_' + action_name + '.rb')) + " " + project_identifier
    if action_name == @@ACTION_CREATE then
      command << " " << Setting.plugin_redmine_ipf_setting_manager['ipf_scm']
    end
    command   
  end
 
end