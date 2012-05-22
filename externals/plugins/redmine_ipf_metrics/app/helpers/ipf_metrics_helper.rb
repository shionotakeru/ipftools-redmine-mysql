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

module IpfMetricsHelper

  #
  #=== Metrics list creation 
  #
  def IpfMetricsList(project = nil)
    @project = project
    @metrics_list = []
    @metrics = Metrics.find(:all, :order => "id")
    if @project
      @tracker = @project.trackers
    else
      @tracker = Tracker.all
    end
    @tracker.each do |tracker_row|
      if @project
        @metrics_link = MetricsLink.find(:first, :conditions=>[ "(project_id = ? or project_id is null) and tracker_id = ?",
                                                                @project.id, tracker_row.id ],
                                                                :order => "project_id")
      else
        @metrics_link = MetricsLink.find(:first, :conditions=>[ "project_id is null and tracker_id = ?",
                                                                tracker_row.id ])
      end
      rec = []
      rec << tracker_row.name
      group = sprintf("metrics_%d", tracker_row.id) 
      rec << group
      metrics = []
      @metrics.each do |item|
        metrics_ent = []
        metrics_ent << item["id"]
        metrics_ent << item["name"]
        if @metrics_link
          if item["id"] == @metrics_link.metrics_id
            metrics_ent << true
          else
            metrics_ent << false
          end
        elsif item.id == 4
          metrics_ent << true
        end
        metrics << metrics_ent
      end      
      rec << metrics
      @metrics_list << rec
    end
  end

  #
  #=== Graph Pattern list creation 
  #
  def IpfGraphPatternList(project = nil)
    @project = project
    if @project == nil
      @graph_pattern = GraphPattern.find(:all, :conditions=>[ "project_id is null" ] )
    else
      @graph_pattern = GraphPattern.find(:all, :conditions=>[ "project_id = ?", @project.id ] )
    end
    return
  end

  #
  #=== Authority judging processing 
  #
  def permission(user_id, project_id, module_name, permission)
    enabled_module = EnabledModule.find(:all, :conditions => ["project_id = ? and name = ?",
                                                              project_id, module_name])
    return false unless enabled_module.size > 0

    @members = Member.find_all_by_user_id_and_project_id(user_id, project_id)
    @members.each do |member|
      member.member_roles.each do |memberrole|
        role = Role.find(memberrole.role_id)
        role.permissions.each do |permission_name|
          if permission_name.to_s == permission
            return true
          end
        end
      end
    end
    return false
  end
  
end
