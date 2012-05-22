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


require 'query' 
require 'rexml/document'
require 'tempfile'
require 'date'

module Redmine
  module Export
    module XML
    unloadable

    #
    #=== Data extraction processing 
    #
    #_issues_  :: Issues information
    #_project_ :: Project information 
    #_query_   :: Query information 
    #_options_ :: Option configuration information 
    #
    def issues_to_xml2(issues, project, query, options = {})

        priority_level = Hash.new
        prioritys = Enumeration.find(:all, :conditions => "type = 'IssuePriority'")
        prioritys.each do |priority|
          priority_level[priority.id] = 1000 / prioritys.size * priority.position
        end
        custom_field = CustomField.find_by_name(l(:key_ipf_custom_field_name))
        wbs_id = custom_field.id 
        start_date = Date.new(9999,12,31)
        metrics = Metrics.find_by_name(l(:key_ipf_metrics_name_wbs))
        metrics_link = MetricsLink.find(:all,
                                        :conditions => 
                                        ["project_id = ? and metrics_id = ?", project.id, metrics.id])
        @tracker = Hash.new
        if metrics_link.size > 0
          metrics_link.each do |link|
            @tracker[link.tracker_id] = link.id
          end
        else
          metrics_link = MetricsLink.find(:all,
                                          :conditions => 
                                          ["project_id is null and metrics_id = ?", metrics.id])
          metrics_link.each do |link|
            @tracker[link.tracker_id] = link.id
          end
        end
        
        issues.each do |issue|
          if issue.start_date
            if start_date > issue.start_date
              start_date = issue.start_date
            end
          end
        end
        cnt = 0

        # xml rows
        doc = REXML::Document.new
        doc << REXML::XMLDecl.new('1.0', 'UTF-8')
        project = doc.add_element("Project", {"xmlns" => "http://schemas.microsoft.com/project"})
        project.add_element("ProjectExternallyEdited").add_text("0")
        project.add_element("StartDate").add_text(start_date.strftime("%Y-%m-%dT%H:%M:%S"))
        tasks = project.add_element("Tasks", "")
        issues.each do |issue|
          next unless @tracker[issue.tracker_id]
          cnt += 1
          
          wbs_rec = CustomValue.find(:first, :conditions => ["custom_field_id = ? and customized_id = ?", wbs_id, issue.id]) 
          if wbs_rec.value.empty?
            wbs = "0"
            level = 1
          else
            wbs = wbs_rec.value
            level = wbs.count('.')
          end
          task  = tasks.add_element("Task", "")
          task.add_element("UID").add_text(sprintf("%d", cnt))
          task.add_element("ID").add_text(sprintf("%d", cnt))
          task.add_element("IsNull").add_text("0")
          task.add_element("Name").add_text(issue.subject)
          task.add_element("CreateDate").add_text(issue.created_on.strftime("%Y-%m-%dT%H:%M:%S"))
          task.add_element("Priority").add_text(sprintf("%d", priority_level[issue.priority_id]))
          task.add_element("PercentComplete").add_text(sprintf("%d", issue.done_ratio))
          task.add_element("WBS").add_text(wbs)
          task.add_element("OutlineNumber").add_text(wbs)
          task.add_element("OutlineLevel").add_text(sprintf("%d", level))
          if issue.start_date && issue.start_date != ""
            task.add_element("Start").add_text(issue.start_date.strftime("%Y-%m-%dT08:00:00"))
          else
            task.add_element("Start").add_text("")
          end
          if issue.due_date && issue.due_date != ""
            task.add_element("Finish").add_text(issue.due_date.strftime("%Y-%m-%dT17:00:00"))
          else
            task.add_element("Finish").add_text("")
          end
          if  issue.start_date && issue.start_date != "" &&
              issue.due_date && issue.due_date != ""
            duration_count = 0
            issue.start_date.upto(issue.due_date) {|x|
              logger.debug(x.to_s)
              case x.wday
                when 1, 2, 3, 4, 5 then
                  duration_count += 1
              end
            }
            task.add_element("Duration").add_text(sprintf("PT%dH0M0S", duration_count * 8))
          end
          task.add_element("FixedCostAccrual").add_text("3")
          task.add_element("ConstraintType").add_text("4")
          if issue.start_date && issue.start_date != ""
            task.add_element("ConstraintDate").add_text(issue.start_date.strftime("%Y-%m-%dT08:00:00"))
          else
            task.add_element("ConstraintDate").add_text("")
          end
          task.add_element("Estimated").add_text("1")

        end

        tmpfile = Tempfile.new("ipf_xml_doc")
        doc.write(tmpfile)
        tmpfile.close
        tmpfile.open
        xml_text = tmpfile.read

        return xml_text
      end
    
    end

  end

end

