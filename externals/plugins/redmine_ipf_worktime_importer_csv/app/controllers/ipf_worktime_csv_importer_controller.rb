require "csv"
# -*- coding: utf-8 -*-
require 'fastercsv'
require 'tempfile'
require 'nkf'

#
#=== The importer for man day information CSV 
#
# Import processing of the man day information by the file of CSV is performed. 
# 
#
class IpfWorktimeCsvImporterController < ApplicationController
  unloadable
  
  before_filter :find_project
  before_filter :authorize,:except => :result

  WORKTIME_ATTRS = [:time_entry_id,
                    :time_entry_project,
                    :time_entry_user,
                    :time_entry_issue_id,
                    :time_entry_hours,
                    :time_entry_comments,
                    :time_entry_activity,
                    :time_entry_spent_on]

  def index
  end

  #
  #=== Matching information setup
  #
  def match
    file = params[:file]
    splitter = params[:splitter]
    wrapper = params[:wrapper]
    encoding = params[:encoding]

    if file == nil 
      flash.now[:error] = l(:ipf_wt_imp_csv_label_file_undefined);
      redirect_to :action => "index", :project_id => params[:project_id]
      return
    end
    
    @original_filename = file.original_filename
    ext = File.extname(@original_filename)
    if ext == ".csv"
      @ext = ext
    else
      flash[:error] = l(:ipf_wt_imp_csv_label_extension_besides)
      redirect_to :action => "index", :project_id => params[:project_id]
      return
    end
    tmpfile = File.open(sprintf("%s/ipf_worktime_csv_importer_%s_%s.csv", Dir.tmpdir,
                                                               @project.identifier,
                                                               User.current.login),"wb")
    if tmpfile
      tmpfilename = tmpfile.path
      tmpfile.write(convert_file(file, encoding))
      tmpfile.close
    else
      flash[:error] = "Cannot save import file."
      redirect_to :action => "index", :project_id => params[:project_id]
      return
    end
    
    session[:importer_tmpfile] = tmpfilename
    session[:importer_splitter] = splitter
    session[:importer_wrapper] = wrapper
    session[:importer_encoding] = encoding
    
    sample_count = 5
    i = 0
    @samples = []

    FasterCSV.foreach(tmpfilename, {:headers=>true, :encoding=>"UTF-8", :quote_char=>wrapper, :col_sep=>splitter}) do |row|
      @samples[i] = row
      i += 1
      if i >= sample_count
        break
      end
    end

    if @samples.size > 0
      @headers = @samples[0].headers
    end
 
    if @headers
      @headers.each { |h|
        if h.blank?
          flash[:error] = l(:ipf_wt_imp_csv_label_header_blank);
          redirect_to :action => "index", :project_id => params[:project_id]
          return
        end
      }
    else
      flash[:error] = l(:ipf_wt_imp_csv_error_nodata);
      redirect_to :action => "index", :project_id => params[:project_id]
      return
    end

    @attrs = Array.new
    WORKTIME_ATTRS.each do |attr|
      @attrs.push([l("field_#{attr}".to_sym), attr])
    end
    @attrs.sort! {|x,y| x[0] <=> y[0]}
     
  end

  #
  #=== Issue data registration 
  #
  def result
    begin
      tmpfilename = session[:importer_tmpfile]
      splitter = session[:importer_splitter]
      wrapper = session[:importer_wrapper]
      encoding = session[:importer_encoding]
      
      if tmpfilename
        unless File.exist?(tmpfilename)
          flash.now[:error] = l(:ipf_wt_imp_csv_label_missing_imported_file)
          return
        end
      else
        flash.now[:error] = l(:ipf_wt_imp_csv_label_missing_imported_file)
        return
      end
  
      update_worktime = params[:update_worktime]
      unique_field = params[:unique_field]
      ignore_non_exist = params[:ignore_non_exist]
      fields_map = params[:fields_map]
      unique_attr = fields_map[unique_field] if unique_field
  
      if update_worktime && unique_attr == nil
        flash.now[:error] = l(:ipf_wt_imp_xls_label_unique_field_an_match)
        return
      end
  
      @handle_count = 0
      @update_count = 0
      @skip_count = 0
      @failed_count = 0
      @failed_worktime = Hash.new
      @affect_projects_worktime = Hash.new
  
      attrs_map = fields_map.invert if fields_map
  
      FasterCSV.foreach(tmpfilename, {:headers=>true, :encoding=>'UTF-8', :quote_char=>wrapper, :col_sep=>splitter}) do |row|
  
        @handle_count += 1
        wt_project = Project.find(:first, :conditions => ["name = ?", row[attrs_map["time_entry_project"]]])
        wt_user = @project.users.find(:first, :conditions => ["login = ?", row[attrs_map["time_entry_user"]]])
        wt_issue = @project.issues.find(:first, :conditions => ["id = ?", row[attrs_map["time_entry_issue_id"]]])
        wt_hours = row[attrs_map["time_entry_hours"]]
        wt_comments = row[attrs_map["time_entry_comments"]]
        wt_activity = Enumeration.find(:first, :conditions => ["name = ? and type = 'TimeEntryActivity'", row[attrs_map["time_entry_activity"]]])
        wt_spent_on = row[attrs_map["time_entry_spent_on"]]
  
        if wt_project == nil
          flash.now[:error] = l(:ipf_wt_imp_xls_error_project, :project => row[attrs_map["time_entry_project"]])
          @failed_count += 1
          @failed_worktime[@failed_count-1] = row
          break
        elsif wt_project.id != @project.id
          flash.now[:error] = l(:ipf_wt_imp_xls_error_project_id, :project => row[attrs_map["time_entry_project"]])
          @failed_count += 1
          @failed_worktime[@failed_count-1] = row
          break
        end
        if wt_user == nil
          flash.now[:error] = l(:ipf_wt_imp_xls_error_user, :user => row[attrs_map["time_entry_user"]])
          @failed_count += 1
          @failed_worktime[@failed_count-1] = row
          break
        end
  
        if wt_issue == nil
          flash.now[:error] = l(:ipf_wt_imp_xls_error_issue, :issue => row[attrs_map["time_entry_issue_id"]])
          @failed_count += 1
          @failed_worktime[@failed_count-1] = row
          break
        end
  
        if wt_activity == nil
          flash.now[:error] = l(:ipf_wt_imp_xls_error_activity, :activity => row[attrs_map["time_entry_activity"]])
          @failed_count += 1
          @failed_worktime[@failed_count-1] = row
          break
        end
  
        time_entry = TimeEntry.new
  
        if update_worktime
          if unique_attr == "time_entry_id"
            time_entrys = [TimeEntry.find_by_id(row[unique_field])]
          else
            query = Query.new(:name => "_ipf_worktime_xls_importer", :project => @project)
            query.add_filter(unique_attr, "=", [row[unique_field]])
  
            time_entrys = TimeEntry.find :all, :conditions => query.statement, :limit => 2, :include => [ :wt_user,
                                                                                                          :wt_issue,
                                                                                                          :wt_activity]
          end
  
          if time_entrys.size > 1
            flash.now[:error] = l(:ipf_wt_imp_xls_error_dup, :unique_field => unique_field)
            @failed_count += 1
            @failed_worktime[@failed_count-1] = row
            break
          else
            work_entry = time_entrys.first
            if work_entry != nil
              time_entry = work_entry
            else
              if ignore_non_exist
                @skip_count += 1
                next
              else
                flash.now[:error] = l(:ipf_wt_imp_csv_error_worktime, :time_entry => row[attrs_map["time_entry_id"]])
                @failed_count += 1
                @failed_worktime[@failed_count-1] = row
                break
              end
            end
          end
        end
        
        if wt_project == nil
          flash.now[:error] = l(:ipf_wt_imp_xls_error_project, :project => row[attrs_map["time_entry_project"]])
          @failed_count += 1
          @failed_worktime[@failed_count-1] = row
          break
        end
  
        time_entry.project_id = wt_project != nil ? wt_project.id : @project.id
        time_entry.user_id = wt_user != nil ? wt_user.id : User.current.id
        time_entry.issue_id = wt_issue != nil ? wt_issue.id : nil
        time_entry.hours = wt_hours
        time_entry.comments = wt_comments
        time_entry.activity_id = wt_activity != nil ? wt_activity.id : nil
        time_entry.spent_on = wt_spent_on
        time_entry.updated_on = nil
  
        if (!time_entry.save)
          logger.error("SAVE ERROR LIST START")
          time_entry.errors.each do |error|
            logger.error(error)
          end
          logger.error("SAVE ERROR LIST END")
          @failed_count += 1
          @failed_worktime[@failed_count-1] = row
        else
          @update_count += 1
          @affect_projects_worktime.has_key?(wt_project.name) ?
            @affect_projects_worktime[wt_project.name] += 1 : @affect_projects_worktime[wt_project.name] = 1
        end
      end
  
      if @failed_worktime.size > 0
        @failed_worktime = @failed_worktime.sort
        @headers = @failed_worktime[0][1].headers
      end
    ensure
      File.delete(tmpfilename)
    end  
  end

private

  #
  # Project information acquisition processing 
  #
  def find_project
    begin
      @project = Project.find(params[:project_id])
    rescue ActiveRecord::RecordNotFound
      render_404
    end
  end

  #
  #=== File reading & Character encoding conversion process 
  #
  #_file_ :: File object
  #_encodeing_ :: Character encoding
  #
  def convert_file(file, encoding)
    nkf_option = nil
    nkf_option = '-Sw' if encoding == 'S'
    nkf_option = '-Ew' if encoding == 'EUC'
    nkf_option ? NKF.nkf('-m0 -x -Lu ' + nkf_option, file.read) : file.read 
  end

end
