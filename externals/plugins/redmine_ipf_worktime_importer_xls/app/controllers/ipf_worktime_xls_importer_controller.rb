require 'tempfile'
require 'rubygems'
require 'roo'

#
#=== The importer for man day information Excel
#
# Import processing of the man day information by 
# the file of Excel2003-2007 form is performed
#
class IpfWorktimeXlsImporterController < ApplicationController
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
      flash[:error] = l(:ipf_wt_imp_xls_label_file_undefined)
      redirect_to :action => "index", :project_id => params[:project_id]
      return
    end

    @original_filename = file.original_filename
    session[:ipf_worktime_xls_importer_original_filename] = @original_filename
    ext = File.extname(@original_filename)
    if ext == ".xlsx" || ext == ".xls" 
      @ext = ext
    else
      flash[:error] = l(:ipf_wt_imp_xls_label_extension_besides)
      redirect_to :action => "index", :project_id => params[:project_id]
      return
    end

    tmpfile = File.open(sprintf("%s/ipf_worktime_xls_importer_%s_%s%s", Dir.tmpdir,
                                                               @project.identifier,
                                                               User.current.login,
                                                               @ext),"wb")
    if tmpfile
      tmpfilename = tmpfile.path
      tmpfile.write(file.read)
      tmpfile.close
    else
      flash[:error] = l(:ipf_wt_imp_xls_label_cannot_save_import_file)
      redirect_to :action => "index", :project_id => params[:project_id]
      return
    end

    session[:ipf_worktime_xls_importer_tmpfile] = tmpfilename

    sheet = Roo::Spreadsheet.open(tmpfilename)
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

    tmpfilename = session[:ipf_worktime_xls_importer_tmpfile]
    session[:ipf_worktime_xls_importer_sheetname] = sheetname
    @original_filename = session[:ipf_worktime_xls_importer_original_filename]

    if tmpfilename
      unless File.exist?(tmpfilename)
        flash.now[:error] = l(:ipf_wt_imp_xls_label_missing_imported_file)
        return
      end
    else
      flash.now[:error] = l(:ipf_wt_imp_xls_label_missing_imported_file)
      return
    end

    session[:ipf_worktime_xls_importer_sheetname] = sheetname
    
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
      flash[:error] = l(:ipf_wt_imp_xls_error_nodata);
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
        flash[:error] = l(:ipf_wt_imp_xls_label_header_blank)
        redirect_to :action => "index", :project_id => params[:project_id]
        return
      end
    }

    @attrs = Array.new
    WORKTIME_ATTRS.each do |attr|
      @attrs.push([l("field_#{attr}".to_sym), attr])
    end
    @attrs.sort! {|x,y| x[0] <=> y[0]}
     
  end

  #
  # Data registration
  #
  def result
    tmpfilename = session[:ipf_worktime_xls_importer_tmpfile]
    sheetname = session[:ipf_worktime_xls_importer_sheetname]

    if tmpfilename
      unless File.exist?(tmpfilename)
        flash.now[:error] = l(:ipf_wt_imp_xls_label_missing_imported_file)
        return
      end
    else
      flash.now[:error] = l(:ipf_wt_imp_xls_label_missing_imported_file)
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
      
    read_excel(tmpfilename, sheetname) do |row|
  
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
              flash.now[:error] = l(:ipf_wt_imp_xls_error_worktime, :time_entry => row[attrs_map["time_entry_id"]])
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
      @headers = @failed_worktime[0][1].keys
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
  #_filepath_   :: Excel (temp file) path
  #_sheet_name_ :: Object sheet name
  #
  def read_excel(filepath, sheet_name)
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

end
