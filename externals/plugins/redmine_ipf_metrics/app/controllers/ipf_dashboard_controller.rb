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

require 'logger'
require 'dashboard'
require 'member'
require 'project'
require 'graph_pattern'

#
#= Dashboard setting screen controller 
#
class IpfDashboardController < ApplicationController
  include IpfMetricsHelper

  unloadable

  #
  #=== The contents list display of a dashboard setting 
  #=== File designation display 
  #
  def index
    require_login || return

    @user_id = User.current.id
    @members = Member.find_all_by_user_id(@user_id)

    @pattern_list = []
    @members.each do |member|
      project = Project.find(member.project_id)
      dashboard = Dashboard.find_by_project_id_and_user_id(member.project_id, @user_id)
      pattern = Hash.new
      pattern["project_id"] = project.id
      pattern["project_name"] = project.name
      if dashboard && dashboard.graph_pattern_id != nil 
        graph_pattern = GraphPattern.find(dashboard.graph_pattern_id)
        pattern["name"] = graph_pattern.name  
        pattern["explanation"] = graph_pattern.explanation
        pattern["jsp"] = graph_pattern.jsp
      else
        pattern["name"] = ""  
        pattern["explanation"] = ""
        pattern["jsp"] = ""
      end
      @pattern_list << pattern
    end
    
    return
  end

  #
  #=== The dashboard selection display classified by project 
  #
  def list
    @user_id = User.current.id
    @project_id = params["project_id"]
    find_project
    graph_patterns = GraphPattern.find(:all,
                                       :conditions =>
                                       [ "project_id is null or project_id = ?",
                                       @project_id],
                                       :order => "project_id desc, id asc")
    dashboard = Dashboard.find_by_project_id_and_user_id(@project_id, @user_id)

    @pattern_list = []
    pattern = Hash.new
    pattern["checked"] = true if !dashboard || dashboard.graph_pattern_id == nil
    pattern["id"] = ""
    pattern["name"] = l(:label_ipf_dashboard_default_name)
    pattern["explanation"] = l(:label_ipf_dashboard_default_explanation)
    pattern["jsp"] = l(:label_ipf_dashboard_default_jsp)
    @pattern_list << pattern
    graph_patterns.each do |graph_pattern|
      pattern = Hash.new
      pattern["checked"] = true if dashboard && dashboard.graph_pattern_id == graph_pattern.id
      pattern["id"] = graph_pattern.id
      pattern["name"] = graph_pattern.name
      pattern["explanation"] = graph_pattern.explanation
      pattern["jsp"] = graph_pattern.jsp
      @pattern_list << pattern
    end

  end
  
  #
  #=== Renewal of a dashboard setup 
  #
  def setup
    begin
      @user_id = User.current.id
      @project_id = params["project_id"]
      @graph_pattern_id = params["dashboard"]
      Dashboard.transaction do
        dashboard = Dashboard.find_by_project_id_and_user_id(@project_id, @user_id)
        if dashboard
          dashboard.graph_pattern_id = @graph_pattern_id 
          dashboard.save!
        else
          dashboard = Dashboard.new
          dashboard.user_id           = @user_id 
          dashboard.project_id        = @project_id
          dashboard.graph_pattern_id  = @graph_pattern_id
          dashboard.save!
        end
        flash[:notice] = l(:message_ipf_dashboard_regist)
        redirect_to :action => "index", :project_id => params[:project_id]
      end
    rescue => e
      flash[:error] = l(:message_ipf_dashboard_not_regist)
      redirect_to :action => "index", :project_id => params[:project_id]
    end
  end

  private
  #
  #=== Project information acquisition 
  #
  def find_project
    @project = Project.find(params[:project_id])
  end

end
