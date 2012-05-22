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
require 'graph_pattern'

#
#= Graph pattern setup (project) 
#
class IpfGraphPatternProjectController < ApplicationController
  include IpfMetricsHelper

  unloadable
  before_filter :find_project

  #
  #=== Initial registration display 
  #
  def new
    @name = params["name"]
    @explanation = params["explanation"]
    @jsp = params["jsp"]
  end
  
  #
  #=== New pattern registration processing 
  #
  def new_entry
    begin
      GraphPattern.transaction do
        @name = params["name"]
        @explanation = params["explanation"]
        @jsp = params["jsp"]
        if @name == nil || @name == ""
          flash.now[:error] = l(:message_ipf_graph_pattern_name_nil)
          render :action => "new"
          return
        end
        if @jsp == nil || @jsp == ""
          flash.now[:error] = l(:message_ipf_graph_pattern_name_jsp)
          render :action => "new"
          return
        end
        if @explanation == nil || @explanation == "" 
          flash.now[:error] = l(:message_ipf_graph_pattern_name_explanation)
          render :action => "new"
          return
        end

        names = GraphPattern.find(:all,
                                  :conditions=>[ "project_id is null and name = ?",
                                  @name ])
        if names.size > 0
          flash.now[:error] = l(:message_ipf_graph_pattern_name_duplicat_grobal)
          render :action => "new"
          return
        end
        names = GraphPattern.find(:all,
                                  :conditions=>[ "project_id = ? and name = ?",
                                  @project.id, @name ])
        if names.size > 0
          flash.now[:error] = l(:message_ipf_graph_pattern_name_duplicat_project)
          render :action => "new"
          return
        end
        
        jsps = GraphPattern.find(:all,
                                 :conditions=>[ "project_id is null and jsp = ?",
                                 @jsp ])
        if jsps.size > 0
          flash.now[:error] = l(:message_ipf_graph_pattern_jsp_duplicat_grobal)
          render :action => "new"
          return
        end
        jsps = GraphPattern.find(:all,
                                 :conditions=>[ "project_id = ? and jsp = ?",
                                 @project.id, @jsp ])
        if jsps.size > 0
          flash.now[:error] = l(:message_ipf_graph_pattern_jsp_duplicat_project)
          render :action => "new"
          return
        end
        graphpattern = GraphPattern.new
        graphpattern.project_id = @project.id
        graphpattern.name = @name
        graphpattern.explanation = @explanation
        graphpattern.jsp = @jsp
        graphpattern.save!
        flash[:notice] = l(:message_ipf_graph_pattern_regist)
        respond_to do |format|
          format.html { redirect_to :controller => 'projects', :action => 'settings', :tab => 'ipfgraphpatternproject', :id => @project }
          format.js { 
            render(:update) {|page| 
              page.replace_html "tab-content-ipfgraphpatternproject", :partial => 'projects/settings/ipfgraphpatternproject'
              page << 'hideOnLoad()'
            }
          }
        end
      end
    rescue => e
      flash[:error] = l(:message_ipf_graph_pattern_not_regist)
      respond_to do |format|
        format.html { redirect_to :controller => 'projects', :action => 'settings', :tab => 'ipfgraphpatternproject', :id => @project }
        format.js { 
          render(:update) {|page| 
            page.replace_html "tab-content-ipfgraphpatternproject", :partial => 'projects/settings/ipfgraphpatternproject'
            page << 'hideOnLoad()'
          }
        }
      end
    end
  end

  #
  #=== Renewal display of a pattern 
  #
  def update
    pattern = GraphPattern.find(params["pattern_id"])
    @pattern_id = params["pattern_id"]
    @name = pattern.name
    @explanation = pattern.explanation
    @jsp = pattern.jsp
  end
  
  #
  #=== Pattern update process 
  #
  def update_entry
    begin
      GraphPattern.transaction do
        @pattern_id = params["pattern_id"]
        @name = params["name"]
        @explanation = params["explanation"]
        @jsp = params["jsp"]
        if @name == nil || @name == ""
          flash.now[:error] = l(:message_ipf_graph_pattern_name_nil)
          render :action => "update"
          return
        end
        if @explanation == nil || @explanation == ""
          flash.now[:error] = l(:message_ipf_graph_pattern_name_explanation)
          render :action => "update"
          return
        end
        names = GraphPattern.find(:all,
                                  :conditions=>[ "project_id is null and name = ? and id != ?",
                                  @name, @pattern_id ])
        if names.size > 0
          flash.now[:error] = l(:message_ipf_graph_pattern_name_duplicat_grobal)
          render :action => "update"
          return
        end
        names = GraphPattern.find(:all,
                                  :conditions=>[ "project_id = ? and name = ? and id != ?",
                                  @project.id, @name, @pattern_id ])
        if names.size > 0
          flash.now[:error] = l(:message_ipf_graph_pattern_name_duplicat_project)
          render :action => "update"
          return
        end
        graphpattern = GraphPattern.find(@pattern_id)
        graphpattern.name = @name
        graphpattern.explanation = @explanation
        graphpattern.save!
        flash[:notice] = l(:message_ipf_graph_pattern_update)
        respond_to do |format|
          format.html { redirect_to :controller => 'projects', :action => 'settings', :tab => 'ipfgraphpatternproject', :id => @project }
          format.js { 
            render(:update) {|page| 
              page.replace_html "tab-content-ipfgraphpatternproject", :partial => 'projects/settings/ipfgraphpatternproject'
              page << 'hideOnLoad()'
            }
          }
        end
      end
    rescue => e
      flash[:error] = l(:message_ipf_graph_pattern_not_update)
      respond_to do |format|
        format.html { redirect_to :controller => 'projects', :action => 'settings', :tab => 'ipfgraphpatternproject', :id => @project }
        format.js { 
          render(:update) {|page| 
            page.replace_html "tab-content-ipfgraphpatternproject", :partial => 'projects/settings/ipfgraphpatternproject'
            page << 'hideOnLoad()'
          }
        }
      end
    end
  end
  
  #
  #=== Pattern deletion display 
  #
  def delete
    @pattern_id = params["pattern_id"]
    pattern = GraphPattern.find(@pattern_id)
    @name = pattern.name
    @explanation = pattern.explanation
    @jsp = pattern.jsp
    dashboards = Dashboard.find(:all,
                                :conditions =>
                                [ "graph_pattern_id = ?",
                                @pattern_id ])
    if dashboards.size > 0
      flash.now[:warning] = l(:message_ipf_graph_pattern_using_pattern)
    end
  end
  
  #
  #=== Pattern delete process 
  #
  def delete_entry
    begin
      GraphPattern.transaction do
        @pattern_id = params["pattern_id"]
        @name = params["name"]
        @explanation = params["explanation"]
        @jsp = params["jsp"]
        dashboards = Dashboard.find(:all,
                                    :conditions =>
                                    [ "graph_pattern_id = ?",
                                    @pattern_id ])
        dashboards.each do |dashboard|
          dashboard.graph_pattern_id = nil
          dashboard.save!
        end
        pattern = GraphPattern.find(@pattern_id)
        pattern.destroy
        flash[:notice] = l(:message_ipf_graph_pattern_delete)
        respond_to do |format|
          format.html { redirect_to :controller => 'projects', :action => 'settings', :tab => 'ipfgraphpatternproject', :id => @project }
          format.js { 
            render(:update) {|page| 
              page.replace_html "tab-content-ipfgraphpatternproject", :partial => 'projects/settings/ipfgraphpatternproject'
              page << 'hideOnLoad()'
            }
          }
        end
      end
    rescue => e
      flash[:error] = l(:message_ipf_graph_pattern_not_delete)
      respond_to do |format|
        format.html { redirect_to :controller => 'projects', :action => 'settings', :tab => 'ipfgraphpatternproject', :id => @project }
        format.js { 
          render(:update) {|page| 
            page.replace_html "tab-content-ipfgraphpatternproject", :partial => 'projects/settings/ipfgraphpatternproject'
            page << 'hideOnLoad()'
          }
        }
      end
    end
  end

  private
  #
  #=== Project information acquisition 
  #
  def find_project
    @project = Project.find_by_identifier(params[:project_id])
  end

end
