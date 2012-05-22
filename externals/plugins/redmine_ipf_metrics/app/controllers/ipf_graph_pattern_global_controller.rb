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
#= Graph pattern setup (global) 
#
class IpfGraphPatternGlobalController < ApplicationController
  layout 'admin'
  before_filter :require_admin
  helper :sort
  include SortHelper  
  include IpfMetricsHelper

  unloadable

  #
  #=== Graph pattern list display 
  #
  def index
#    @@project = @project
#    IpfGraphPatternList(@project)
    @@project = nil
    IpfGraphPatternList(nil)
    
    return
  end

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
        @warning = params["warning"]
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
        names = GraphPattern.find(:all, :conditions=>[ "project_id is null and name = ?", @name ])
        if names.size > 0
          flash.now[:error] = l(:message_ipf_graph_pattern_name_duplicat)
          render :action => "new"
          return
        end
        jsps = GraphPattern.find(:all, :conditions=>[ "project_id is null and jsp = ?", @jsp ])
        if jsps.size > 0
          flash.now[:error] = l(:message_ipf_graph_pattern_jsp_duplicat)
          render :action => "new"
          return
        end
        unless @warning == "true"
          jsps = GraphPattern.find(:all, :conditions=>[ "project_id is not null and jsp = ?", @jsp ])
          if jsps.size > 0
            flash.now[:warning] = l(:message_ipf_graph_pattern_jsp_existence_project)
            @warning = true
            render :action => "new"
            return
          end
        end

        graphpattern = GraphPattern.new
        graphpattern.project_id = nil
        graphpattern.name = @name
        graphpattern.explanation = @explanation
        graphpattern.jsp = @jsp
        graphpattern.save!
        grobal_id = GraphPattern.find(:first,
                                      :conditions =>
                                        [ "project_id is null and jsp = ?",
                                        params["jsp"] ])
        patterns = GraphPattern.find(:all,
                                     :conditions =>
                                      [ "project_id is not null and jsp = ?",
                                      params["jsp"] ])
        patterns.each do |pattern|
          dashboards = Dashboard.find(:all,
                                      :conditions =>
                                      [ "project_id = ? and graph_pattern_id = ?",
                                      pattern.project_id, pattern.id ])
          dashboards.each do |dashboard|
            dashboard.graph_pattern_id = grobal_id.id
            dashboard.save!
          end
          pattern.destroy
        end
        flash[:notice] = l(:message_ipf_graph_pattern_regist)
        redirect_to :action => "index", :project_id => params[:project_id]
      end
    rescue => e
      flash[:error] = l(:message_ipf_graph_pattern_not_regist)
      redirect_to :action => "index", :project_id => params[:project_id]
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
          flash.now[:error] = l(:message_ipf_graph_pattern_name_duplicat)
          render :action => "update"
          return
        end
        graphpattern = GraphPattern.find(@pattern_id)
        graphpattern.name = @name
        graphpattern.explanation = @explanation
        graphpattern.save!
        flash[:notice] = l(:message_ipf_graph_pattern_update)
        redirect_to :action => "index", :project_id => params[:project_id]
      end
    rescue => e
      flash[:error] = l(:message_ipf_graph_pattern_not_update)
      redirect_to :action => "index", :project_id => params[:project_id]
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
        redirect_to :action => "index", :project_id => params[:project_id]
      end
    rescue => e
      flash[:error] = l(:message_ipf_graph_pattern_not_delete)
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
