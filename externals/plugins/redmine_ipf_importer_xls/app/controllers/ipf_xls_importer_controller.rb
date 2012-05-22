require "fileutils"
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

require 'tempfile'
require 'tmpdir'
require 'rubygems'
require 'roo'

#
#= The importer for Excel 
#
# Import processing of the ticket by the file
# of Excel2003-2007 form is performed. 
#
class IpfXlsImporterController < ApplicationController
  unloadable

  before_filter :find_project
  before_filter :authorize,:except => :result

  ISSUE_ATTRS = [:id, :project, :subject, :parent_issue, :assigned_to, :fixed_version,
    :author, :description, :category, :priority, :tracker, :status,
    :start_date, :due_date, :done_ratio, :estimated_hours]
  
  #
  #=== File designation display 
  #
  def index
  end

  #
  #=== File reception and sheet name list creation
  #
  def select

    file = params[:file]

    if file == nil 
      flash[:error] = l(:ipf_imp_xls_label_file_undefined);
      redirect_to :action => "index", :project_id => params[:project_id]
      return
    end

    @original_filename = file.original_filename
    session[:ipf_xls_importer_original_filename] = @original_filename
    ext = File.extname(@original_filename)
    if ext == ".xlsx" || ext == ".xls"
      @ext = ext
    else
      flash[:error] = l(:ipf_imp_xls_label_extension_besides )
      redirect_to :action => "index", :project_id => params[:project_id]
      return
    end

    tmpfile = File.open(sprintf("%s/ipf_xls_importer_%s_%s%s", Dir.tmpdir,
                                                               @project.identifier,
                                                               User.current.login,
                                                               @ext),"wb")
    if tmpfile
      tmpfilename = tmpfile.path
      tmpfile.write(file.read)
      tmpfile.close
    else
      flash[:error] = l(:ipf_imp_xls_label_cannot_save_import_file)
      redirect_to :action => "index", :project_id => params[:project_id]
      return
    end

    session[:ipf_xls_importer_tmpfile] = tmpfilename

    sheet = Roo::Spreadsheet.open(tmpfile.path)
    @sheet_name = ""
    sheetnames = sheet.sheets
    sheetnames.each do |name|
      @sheet_name << "<option value=" << name << ">" << name << "</option>"
    end
  end
  
  #
  #=== File reception and a matching information setup
  #
  def match

    sheetname = params[:sheetname]
    session[:ipf_xls_importer_sheetname] = sheetname

    tmpfilename = session[:ipf_xls_importer_tmpfile]
    sheetname = session[:ipf_xls_importer_sheetname]
    @original_filename = session[:ipf_xls_importer_original_filename]

    if tmpfilename
      unless File.exist?(tmpfilename)
        flash.now[:error] = l(:ipf_imp_xls_label_missing_imported_file)
        return
      end
    else
      flash.now[:error] = l(:ipf_imp_xls_label_missing_imported_file)
      return
    end

    session[:ipf_xls_importer_sheetname] = sheetname
    
    sample_count = 5
    i = 0
    @samples = []

    read_excel(tmpfilename, sheetname) do |row|
      @samples[i] = row
      i += 1
      if i >= sample_count
        break
      end
    end
    if i == 0
      flash[:error] = l(:ipf_imp_xls_error_nodata);
      redirect_to :action => "index", :project_id => params[:project_id]
      return
    end

    @headers = []
    if @samples.size > 0
      @headers = @samples[0].keys
      @headers.sort!
    end

    @headers.each { |h|
      if h.blank?
        flash.now[:error] = l(:ipf_imp_xls_label_header_blank);
        redirect_to :action => "index", :project_id => params[:project_id]
        return
      end
    }

    @attrs = Array.new
    ISSUE_ATTRS.each do |attr|
      @attrs.push([l("field_#{attr}".to_sym), attr])
    end
    @project.all_issue_custom_fields.each do |cfield|
      @attrs.push([cfield.name, cfield.name])
    end
    @attrs.sort! {|x,y| x[0] <=> y[0]}
     
  end

  #
  #=== Issue data registration
  #
  def result
    tmpfilename = session[:ipf_xls_importer_tmpfile]
    sheetname = session[:ipf_xls_importer_sheetname]

    if tmpfilename
      unless File.exist?(tmpfilename)
        flash.now[:error] = l(:ipf_imp_xls_label_missing_imported_file)
        return
      end
    else
      flash.now[:error] = l(:ipf_imp_xls_label_missing_imported_file)
      return
    end

    default_tracker = params[:default_tracker]
    update_issue = params[:update_issue]
    unique_field = params[:unique_field]
    journal_field = params[:journal_field]
    update_other_project = params[:update_other_project]
    ignore_non_exist = params[:ignore_non_exist]
    fields_map = params[:fields_map]
    unique_attr = fields_map[unique_field] if unique_field 

    if update_issue && unique_attr == nil
      flash.now[:error] = l(:ipf_imp_xls_label_unique_field_an_match)
      File.delete(tmpfilename)
      return
    end

    @handle_count = 0
    @update_count = 0
    @skip_count = 0
    @failed_count = 0
    @failed_issues = Hash.new
    @affect_projects_issues = Hash.new
    
    attrs_map = fields_map.invert if fields_map
      
    read_excel(tmpfilename, sheetname) do |row|
      @handle_count += 1
      if update_issue != nil && update_other_project != nil
        project = Project.find(:first, :conditions => ["name = ?", row[attrs_map["project"]]])
      end
      tracker = Tracker.find(:first, :conditions => ["name = ?", row[attrs_map["tracker"]]])
      status = IssueStatus.find(:first, :conditions => ["name = ?", row[attrs_map["status"]]])
      if row[attrs_map["author"]]
        author = user_find_condition(row[attrs_map["author"]])
      end
      priority = Enumeration.find_by_name(row[attrs_map["priority"]])
      category = IssueCategory.find_by_name(row[attrs_map["category"]])
      if row[attrs_map["assigned_to"]]
        assigned_to = user_find_condition(row[attrs_map["assigned_to"]]) 
      end
  
      issue = Issue.new
      journal = nil
      issue.project_id = project != nil ? project.id : @project.id
      issue.tracker_id = tracker != nil ? tracker.id : default_tracker
      issue.author_id = author != nil && author.class.name != "AnonymousUser" ? author.id : User.current.id
      fixed_version = Version.find_by_name_and_project_id(row[attrs_map["fixed_version"]], issue.project_id)

      if update_issue
        if !ISSUE_ATTRS.include?(unique_attr.to_sym)
          issue.available_custom_fields.each do |cf|
            if cf.name == unique_attr
              unique_attr = "cf_#{cf.id}"
              break
            end
          end 
        end
        
        if unique_attr == "id"
          issues = [Issue.find_by_id(row[unique_field])]
        else
          query = Query.new(:name => "_ipf_xls_importer", :project => @project)
          query.add_filter("status_id", "*", [1])
          query.add_filter(unique_attr, "=", [row[unique_field]])

          issues = Issue.find :all, :conditions => query.statement, :limit => 2, :include => [ :assigned_to, :status, :tracker, :project, :priority, :category, :fixed_version ]
        end
        
        if issues.size > 1
          flash.now[:error] = l(:ipf_imp_xls_error_dup, :Unique_field => unique_field)
          @failed_count += 1
          @failed_issues[@failed_count-1] = row
          break
        else
          work_issue = issues.first
          if work_issue != nil
            issue = work_issue
            
            if issue.project_id != @project.id && !update_other_project
              @skip_count += 1
              next              
            end
            
            if issue.status.is_closed?
              if status == nil || status.is_closed?
                @skip_count += 1
                next
              end
            end
            
            note = row[journal_field] || ''
            journal = issue.init_journal(author || User.current, note || '')
          else
            logger.debug(sprintf("id = %d", row[unique_field]))
            if ignore_non_exist
              @skip_count += 1
              next
            else
              flash.now[:error] = l(:ipf_imp_xls_error_no_data, :id => row[attrs_map[unique_attr]]) 
              @failed_count += 1
              @failed_issues[@failed_count-1] = row
              break
            end
          end
        end
      end
      
      if project == nil
        project = Project.find_by_id(issue.project_id)
      end

      issue.status_id = status != nil ? status.id : issue.status_id
      issue.priority_id = priority != nil ? priority.id : issue.priority_id
      issue.subject = row[attrs_map["subject"]] || issue.subject
      
      issue.parent_issue_id = row[attrs_map["parent_issue"]] || issue.parent_issue_id
      issue.description = row[attrs_map["description"]] || issue.description
      issue.category_id = category != nil ? category.id : issue.category_id
      issue.start_date = row[attrs_map["start_date"]] || issue.start_date
      issue.due_date = row[attrs_map["due_date"]] || issue.due_date
      issue.assigned_to_id = assigned_to != nil && assigned_to.class.name != "AnonymousUser"? assigned_to.id : issue.assigned_to_id
      issue.fixed_version_id = fixed_version != nil ? fixed_version.id : issue.fixed_version_id
      if row[attrs_map["done_ratio"]]
        row[attrs_map["done_ratio"]] = row[attrs_map["done_ratio"]] * 100
        issue.done_ratio = row[attrs_map["done_ratio"]]
      else
        issue.done_ratio = issue.done_ratio
      end
      issue.estimated_hours = row[attrs_map["estimated_hours"]] || issue.estimated_hours

      issue.custom_field_values = issue.available_custom_fields.inject({}) do |h, c|
        if value = row[attrs_map[c.name]]
          case c.field_format
          when 'int'
            h[c.id] = sprintf("%d", value.to_i)
          when 'float'
            h[c.id] = sprintf("%f", value.to_f)
          when 'date'
            h[c.id] = value.strftime("%Y-%m-%d")
          when 'list'
            h[c.id] = value.to_s
          when 'user'
            h[c.id] = user_find_condition(value.to_s).id.to_s
          else
            h[c.id] = value
          end
        end
        h
      end
      if (!issue.save)
        logger.error("SAVE ERROR LIST START")
        issue.errors.each do |error|
          logger.error(error)
        end
        issue.attributes.each do |name, value|
          logger.error(sprintf("name = %s, value = %s", name, value))
        end
        issue.custom_values.each do |custom_value|
          if custom_value.errors.full_messages.size != 0
            logger.error(sprintf("%s:%s", custom_value.custom_field.name,
                                          custom_value.errors.full_messages))
            logger.error(custom_value.value)
          end
        end
        logger.error("SAVE ERROR LIST END")
        @failed_count += 1
        @failed_issues[@failed_count-1] = row
      else
        @affect_projects_issues.has_key?(project.name) ?
          @affect_projects_issues[project.name] += 1 : @affect_projects_issues[project.name] = 1
        @update_count += 1
      end
  
      if journal
        journal
      end
    end
    logger.error(sprintf("handle_count = %d, @update_count = %d, @skip_count = %d, @failed_count = %d", @handle_count, @update_count, @skip_count, @failed_count))
    
    if @failed_issues.size > 0
      @failed_issues = @failed_issues.sort
      @headers = @failed_issues[0][1].keys
    end
  end

private

  #
  #=== Project information acquisition processing 
  #
  def find_project
    begin
      @project = Project.find(params[:project_id])
    rescue ActiveRecord::RecordNotFound
      render_404
    end
  end

  #
  #=== Excel file deployment processing
  #
  #_filepath_ :: Excel (temp file) path
  #_sheetno_  :: Object sheet number
  #
  def read_excel(filepath, sheet_name)
    logger.debug(sprintf("filepath = %s", filepath))
    logger.debug(sprintf("sheet_name = %s", sheet_name))
    
    sheet = Roo::Spreadsheet.open(filepath)
    header = []
    col_f = sheet.first_column(sheet_name)
    col_l = sheet.last_column(sheet_name)
    row_f = sheet.first_row(sheet_name)
    row_l = sheet.last_row(sheet_name)
    for col_idx in col_f..col_l do
      header << sheet.cell(row_f, col_idx, sheet_name)
    end

    for row_idx in row_f + 1..row_l do
      row = Hash::new
      for col_idx in col_f..col_l do
        if header[col_idx - 1]
          row[header[col_idx - 1]] = sheet.cell(row_idx, col_idx, sheet_name)
        end
      end
      yield row
    end
  end

  def user_find_condition(user_name)

    case Setting.user_format
        when :firstname_lastname
          User.find(:first, :conditions => ["firstname || ' ' || lastname = ?", user_name])
        when :firstname
          User.find(:first, :conditions => ["firstname = ?", user_name])
        when :lastname_firstname
          User.find(:first, :conditions => ["lastname || ' ' || firstname = ?", user_name])
        when :lastname_coma_firstname
          User.find(:first, :conditions => ["lastname || ',' || firstname = ?", user_name])
        when :username
          User.find(:first, :conditions => ["login = ?", user_name])
    end

  end
end
