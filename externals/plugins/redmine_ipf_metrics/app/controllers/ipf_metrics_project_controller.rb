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
require 'metrics'
require 'metrics_link'

#
#= Metrics setup (project) 
#
class IpfMetricsProjectController < ApplicationController
  before_filter :find_project
  unloadable

  #
  #=== Metrics setting processing 
  #
  def entry
    begin
      MetricsLink.transaction do
        if params["commit"] == l(:button_ipf_metrics_cancel)
          flash[:error] = l(:message_ipf_metrics_cancel)
          respond_to do |format|
            format.html { redirect_to :controller => 'projects', :action => 'settings', :tab => 'ipfmetricsproject', :id => @project }
            format.js { 
              render(:update) {|page| 
                page.replace_html "tab-content-ipfmetricsproject", :partial => 'projects/settings/ipfmetricsproject'
                page << 'hideOnLoad()'
              }
            }
          end

          return
        end
        link = Hash::new
        params.each do |param|
          para = param[0].split(/_/)
          if para[0] == "metrics"
            link[para[1]] = param[1]
          end
        end
        project = []
        if @project == nil
          project = Project.find(:all)
          edit_metrics_link(nil, link)
        else
          project = Project.find(:all, :conditions=>[ "id = ?", @project.id ])
        end
        project.each do |project_item|
          edit_metrics_link(project_item.id, link)
        end      
        flash[:notice] = l(:message_ipf_metrics_update)
        respond_to do |format|
          format.html { redirect_to :controller => 'projects', :action => 'settings', :tab => 'ipfmetricsproject', :id => @project }
          format.js { 
            render(:update) {|page| 
              page.replace_html "tab-content-ipfmetricsproject", :partial => 'projects/settings/ipfmetricsproject'
              page << 'hideOnLoad()'
            }
          }
        end
      end
    rescue => e
      flash[:error] = l(:message_ipf_metrics_not_update)
      respond_to do |format|
        format.html { redirect_to :controller => 'projects', :action => 'settings', :tab => 'ipfmetricsproject', :id => @project }
        format.js { 
          render(:update) {|page| 
            page.replace_html "tab-content-ipfmetricsproject", :partial => 'projects/settings/ipfmetricsproject'
            page << 'hideOnLoad()'
          }
        }
      end
    end
    return
  end
  
  private
  #
  #=== Metrics link update process 
  #
  def edit_metrics_link(project_id, link)
    link.each do |link_item|
      metrics_link = MetricsLink.find_by_project_id_and_tracker_id(project_id, link_item[0])
      if metrics_link == nil
        metrics_link = MetricsLink.new
        metrics_link.project_id = project_id
        metrics_link.tracker_id = link_item[0]
        metrics_link.metrics_id = link_item[1]
        metrics_link.save!
      else
        metrics_link.metrics_id = link_item[1]
        metrics_link.save!
      end
    end
  end
  #
  #=== Project information acquisition 
  #
  def find_project
    @project = Project.find(params[:project_id])
  end

end
