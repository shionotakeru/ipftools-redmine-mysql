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

module Redmine
  module Ipf
    module Worktime
	    module Export
    		module XLS
      		unloadable
		
          #
          #=== Data extraction processing 
          #
          #_issues_  :: Issues information
          #_project_ :: Project information 
          #_query_   :: Query information 
          #_options_ :: Option configuration information 
          #
      		def worktime_to_xls2(issues, project, query, options = {})
      			Spreadsheet.client_encoding = 'UTF-8'
      			
      			options.default=false
      			group_by_query = query.grouped? ? options[:group] : false
      	
      			book = Spreadsheet::Workbook.new
      	    
      			issue_columns = []
            worktime_columns = []
      	    
            worktime_columns << IpfQueryColumn.new(:project)
            worktime_columns << IpfQueryColumn.new(:user)
            worktime_columns << IpfQueryColumn.new(:issue_id)
            worktime_columns << IpfQueryColumn.new(:hours)
            worktime_columns << IpfQueryColumn.new(:comments)
            worktime_columns << IpfQueryColumn.new(:activity)
            worktime_columns << IpfQueryColumn.new(:spent_on)
            
      	    sheet1 = nil
      			group = false
      			columns_width = []
      			idx = 0
            # xls rows
      			issues.each do |issue|

      				if group_by_query == '1'
      					new_group=ipf_wt_exp_xls_query_get_group_column_name(issue,query)
      					if new_group != group
      						group = new_group
      						ipf_wt_exp_xls_update_sheet_formatting(sheet1,columns_width) if sheet1
      						sheet1 = book.create_worksheet(:name => (group.blank? ? l(:label_none) : ipf_wt_exp_xls_pretty_xls_tab_name(group.to_s)))
                  columns_width=ipf_wt_exp_xls_init_header_columns(sheet1,worktime_columns)
      						idx = 0
      					end
      				else
      					if sheet1 == nil
      						sheet1 = book.create_worksheet(:name => l(:label_issue_plural))
                  columns_width=ipf_wt_exp_xls_init_header_columns(sheet1,worktime_columns)
      					end
      				end
      			
              time_entrys = TimeEntry.find_all_by_issue_id(issue.id)
              time_entrys.each do |time_entry|
                
                row = sheet1.row(idx+1)

                row.replace [time_entry.id]
        				
        				lf_pos = ipf_wt_exp_xls_get_value_width(time_entry.id)
        				columns_width[0] = lf_pos unless columns_width[0] >= lf_pos
        				
        				last_prj = project
        				
        				worktime_columns.each_with_index do |c, j|
                  v = 
                    case c.name
                      when :project
                        Project.find(time_entry.project_id).name
                      when :user
                        User.find(time_entry.user_id).login
                      when :issue_id
                        time_entry.issue_id
                      when :hours
                        time_entry.hours
                      when :comments
                        descr_str = '' 
                        time_entry.comments.to_s.each_char do |c_a|
                          if c_a != "\r"
                            descr_str << c_a
                          end
                        end
                        descr_str
                      when :activity
                        Enumeration.find(time_entry.activity_id).name
                      when :spent_on
                        time_entry.spent_on
        						else
        							time_entry.respond_to?(c.name) ? time_entry.send(c.name) : c.value(time_entry)
        						end
        					
                  value = ['Time', 'Date', 'Fixnum', 'Float', 'Integer', 'String'].include?(v.class.name) ? v : v.to_s

                  lf_pos = ipf_wt_exp_xls_get_value_width(value)
        					columns_width[j+1] = lf_pos unless columns_width[j+1] >= lf_pos
        					row << value
        				end

                idx = idx + 1
              
              end

      			end
      			
      			if sheet1
      				ipf_wt_exp_xls_update_sheet_formatting(sheet1,columns_width)
      			else
      				sheet1 = book.create_worksheet(:name => 'TimeEntrys')
      				sheet1.row(0).replace [l(:label_no_data)]
      			end

      			xls_stream = StringIO.new('')
      			book.write(xls_stream)
      	    
      			return xls_stream.string
      		end
      		
          #
          #=== Header column width calculation 
          #
          #_sheet1_  :: Excel Sheet
          #_columns_ :: Column Arrey
          #
      		def ipf_wt_exp_xls_init_header_columns(sheet1,columns)
      			
      			columns_width = [1]
      			sheet1.row(0).replace ["id"]
      			
      			columns.each do |c|
      				sheet1.row(0) << c.caption
      				columns_width << (ipf_wt_exp_xls_get_value_width(c.caption)*1.1)
      			end
            # id
      			sheet1.column(0).default_format = Spreadsheet::Format.new(:number_format => "0")
      			
      			opt = Hash.new
      			columns.each_with_index do |c, idx|
      				width = 0
      				opt.clear
      				
      				if c.is_a?(QueryCustomFieldColumn)
      					case c.custom_field.field_format
      						when "int"
      							opt[:number_format] = "0"
      						when "float"
      							opt[:number_format] = "0.00"
      					end
      				else
      					case c.name
      						when :done_ratio
      							opt[:number_format] = '0%'
      						when :hours
      							opt[:number_format] = "0.0"
      					end
      				end

      				sheet1.column(idx+1).default_format = Spreadsheet::Format.new(opt) unless opt.empty?
      				columns_width[idx+1] = width unless columns_width[idx+1] >= width
      			end
      	  
      	  	return columns_width
      		end
      		
          #
          #=== Column attribute setup 
          #
          #_sheet1_  :: Excel Sheet
          #_columns_width_ :: Column width arrey
          #
      		def ipf_wt_exp_xls_update_sheet_formatting(sheet1,columns_width)
      			
      			sheet1.row(0).count.times do |idx|
      				
      					do_wrap = columns_width[idx] > 60 ? 1 : 0
      					sheet1.column(idx).width = columns_width[idx] > 60 ? 60 : columns_width[idx]

      					if do_wrap
      						fmt = Marshal::load(Marshal.dump(sheet1.column(idx).default_format))
      						fmt.text_wrap = true
      						sheet1.column(idx).default_format = fmt
      					end

      					fmt = Marshal::load(Marshal.dump(sheet1.row(0).format(idx)))
      					fmt.font.bold=true
      					fmt.pattern=1
      					fmt.pattern_bg_color=:gray
      					fmt.pattern_fg_color=:gray
      					sheet1.row(0).set_format(idx,fmt)
      			end

      		end

          #
          #=== Data column width calculation 
          #
          #_value_  :: Value
          #
      		def ipf_wt_exp_xls_get_value_width(value)

      			if ['Time', 'Date'].include?(value.class.name)
              return 10 
      			end
      			
      			tot_w = Array.new
      			tot_w << Float(0)
      			idx=0
      			value.to_s.each_char do |c|
      				case c
      					when '1', '.', ';', ':', ',', ' ', 'i', 'I', 'j', 'J', '(', ')', '[', ']', '!', '-', 't', 'l'
      						tot_w[idx] += 0.6
      					when 'W', 'M', 'D'
      						tot_w[idx] += 1.2
      					when "\n"
      						idx = idx + 1
      						tot_w << Float(0)
      				else
                if c =~ /^[ -~｡-ﾟ]*$/
                  tot_w[idx] += 1.05  
                else
                  tot_w[idx] += 2.1  
                end
      				end
      			end
      			
      			wdth=0
      			tot_w.each do |w|
      				wdth = w unless w < wdth 
      			end
      			
      			return wdth + 1.5
      		end

          #
          #=== Group name acquisition 
          #
          #_issue_  :: Issue Information
          #_query_  :: Query Information
          #
      		def ipf_wt_exp_xls_query_get_group_column_name(issue,query)
      			gc=query.group_by_column

      			return issue.send(query.group_by) unless gc.is_a?(QueryCustomFieldColumn)

      			cf=issue.custom_values.detect do |c|
      				true if c.custom_field_id == gc.custom_field.id
      			end

      			return cf==nil ? l(:label_none) : cf.value
      		end

          #
          #=== Sheet name edit 
          #
          #_org_name_  :: Group name
          #
      		def ipf_wt_exp_xls_pretty_xls_tab_name(org_name)
      			return org_name.gsub(/[\\\/\[\]\?\*:"']/, '_')
      		end

      	end

    	end

	  end

	end

end
