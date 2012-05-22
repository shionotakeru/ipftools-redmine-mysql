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
require 'time_entry' 
require 'ipf_query_columns' 
require 'spreadsheet'
require 'fastercsv'

module Redmine
  module Ipf
    module Worktime
	    module Export
    		module CSV
      		unloadable
		
          #
          #=== Data extraction processing 
          #
          #_issues_  :: Issues information
          #_project_ :: Project information 
          #_query_   :: Query information 
          #_options_ :: Option configuration information 
          #
      		def worktime_to_csv2(issues, project, query, options = {})
      	    
            csv_string = FasterCSV.generate do |csv|
              csv << [  l(:field_time_entry_id),
                        l(:field_time_entry_project),
                        l(:field_time_entry_user),
                        l(:field_time_entry_issue_id),
                        l(:field_time_entry_hours),
                        l(:field_time_entry_comments),
                        l(:field_time_entry_activity),
                        l(:field_time_entry_spent_on)
                     ]
        			issues.each do |issue|
                time_entrys = TimeEntry.find_all_by_issue_id(issue.id)
                time_entrys.each do |time_entry|
                  entry_id  = time_entry.id.to_i
                  project   = time_entry.project.to_s
                  user      = User.find(time_entry.user_id).login
                  issue_id  = time_entry.issue_id.to_i
                  hours     = time_entry.hours
                  comments  = time_entry.comments.to_s
                  activity  = time_entry.activity.to_s
                  spent_on  = time_entry.spent_on
                  
                  csv << [ entry_id,
                           project,
                           user,
                           issue_id,
                           hours,
                           comments,
                           activity,
                           spent_on ]
                end
              end
      			end
      			return NKF.nkf('-m0 -x -Lw -c -Ws', csv_string)
      		end
      	end
    	end
	  end
	end
end
