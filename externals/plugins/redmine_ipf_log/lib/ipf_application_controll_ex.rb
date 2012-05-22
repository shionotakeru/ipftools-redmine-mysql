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

require 'pp'
require 'yaml'

#
#= Log output module
#
module IpfApplicationControllEx

  @@log_file = ""
  @@log_interval = ""
  @@log_locale = ""
  @@logger = nil
  @@logging_functions = []

  #
  #=== Initialize for logging
  #
  def self.included(base)
    begin
      self.create_logger
      self.init_logging_functions
    rescue
      @@logger = nil
      @@logging_functions = []
    end

    base.class_eval do
      alias_method_chain :set_localization, :ipf_set_localization
    end
  end

  #
  #=== Replace method for set_localization
  #
  def set_localization_with_ipf_set_localization
    set_localization_without_ipf_set_localization

    option_params = {}

    if params.key?(:ids)
      option_params[:ids] = params[:ids]
    elsif params.key?(:id)
      option_params[:ids] = [params[:id]]
    end

    access_logging(option_params)
  end

  #
  #===Output log
  #
  def access_logging(option_params)
    if @@logger.nil? || @@logging_functions.empty?
      return
    end

    function_found = false

    logging_data = []

    @@logging_functions.each do |func|
      if (func['controller'] == params[:controller]) && (func['action'] == params[:action])
        logging_data = get_logging_values(func, option_params)
        break
      end
    end

    # logging_data values:
    #   nil -> log ignored
    #   [](empty array) -> functions not found
    #   [str, str, str] -> functions found

    return if logging_data.nil?

    function_name, feature_detail, project_name =
      if logging_data.empty?
        project_name = '-'
        if params.key?(:project_id)
          project = Project.find(params[:project_id])
          project_name = project['name']
        end
        ['-', '-', project_name]
      else
        logging_data
      end

    user_name =
      if User.current.login.empty?
        '-'
      else
        User.current.login
      end

    logmsg = [
      user_name,
      request.env['REMOTE_ADDR'],
      project_name,
      function_name,
      feature_detail,
      params[:action],
      params[:controller]
    ].join(',')

    @@logger.info(logmsg)
  end

  private

  #
  #===Initialize output object.
  #
  def self.create_logger
    self.read_log_settings

    @@logger = Logger.new(@@log_file, @@log_interval)
    @@logger.formatter = Logger::Formatter.new
    @@logger.datetime_format = "%Y/%m/%d %H:%M:%S"
  end

  #
  #===Read log configuration
  #
  def self.read_log_settings
    @@log_file = File.join(RAILS_ROOT, 'log', Setting.plugin_redmine_ipf_log['ipf_log_file'])
    @@log_interval = Setting.plugin_redmine_ipf_log['ipf_log_interval']
    @@log_locale = Setting.plugin_redmine_ipf_log['ipf_log_locale']
  end

  #
  #===Create logging target function list
  #
  def self.init_logging_functions
    @@logging_functions = [
      # Export Issues/Failures/WBS
      # Search Issues/Failures/WBS
      # Export Work time Information
      {'controller' => 'issues', 'action' => 'index', 'get_project' => :get_project, 'key_name_proc' => :format_issues_index},
      # Show Issues/Failures/WBS import page
      {'controller' => 'importer', 'action' => 'index', 'get_project' => :get_project},
      {'controller' => 'IpfXlsImporter', 'action' => 'index', 'get_project' => :get_project},
      # Preview Issues/Failures/WBS import
      #{'controller' => '', 'action' => '', 'get_project' => :get_project},
      # CSV Import Issues/Failures/WBS
      {'controller' => 'importer', 'action' => 'result', 'get_project' => :get_project},
      # XLS Import Issues/Failures/WBS
      {'controller' => 'IpfXlsImporter', 'action' => 'result', 'get_project' => :get_project},
      # Show Issues/Failures/WBS new creation page
      {'controller' => 'issues', 'action' => 'new', 'get_project' => :get_project},
      # Create Issues/Failures/WBS
      {'controller' => 'issues', 'action' => 'create', 'get_project' => :get_project},
      # Show Issues/Failures/WBS edit page
      {'controller' => 'issues', 'action' => 'show', 'get_project' => :get_issues_project, 'replace_rules' => {'ticketid' => 'ids'}},
      # Update Issues/Failures/WBS
      {'controller' => 'issues', 'action' => 'update', 'get_project' => :get_issues_project, 'replace_rules' => {'ticketid' => 'ids'}},
      {'controller' => 'issues', 'action' => 'bulk_update', 'get_project' => :get_issues_project, 'replace_rules' => {'ticketid' => 'ids'}},
      # Remove Issues/Failures/WBS
      {'controller' => 'issues', 'action' => 'destroy', 'get_project' => :get_issues_project, 'replace_rules' => {'ticketid' => 'ids'}},
      # Show Work Time page
      # Update Work Time
      {'controller' => 'work_time', 'action' => 'show', 'key_name_proc' => :work_time_show},
      # CSV Import Work Time
      {'controller' => 'IpfWorktimeCsvImporter', 'action' => 'result', 'get_project' => :get_project},
      # XLS Import Work Time
      {'controller' => 'IpfWorktimeXlsImporter', 'action' => 'result', 'get_project' => :get_project},
      # Report Work Time Information
      #{'controller' => '', 'action' => 'show', 'get_project' => :get_project},
      # Show Quantitative Data Collection Condition configuration page
      {'controller' => 'IpfMetricsGlobal', 'action' => 'index'},
      # Configurate Quantitative Data Collection Condition
      {'controller' => 'IpfMetricsGlobal', 'action' => 'entry'},
      # Show Source Volume Data configuration page
      #{'controller' => '', 'action' => ''},
      # Configurate Source Volume Data
      #{'controller' => '', 'action' => ''},
      # Show IPF-Dashboard configuration page
      {'controller' => 'IpfDashboard', 'action' => 'index'},
      # Configurate IPF-Dashboard
      {'controller' => 'IpfDashboard', 'action' => 'setup'},
    ]
  end

  #
  #===Get output log data
  #
  def get_logging_values(function_data, option_params)
    if function_data['get_project']
      # project info needed
      project = send(function_data['get_project'], option_params)
      if project.nil?
        # cannot get project, log ignored
        return nil
      end

      unless check_module_enabled?(project['id'])
        # log module disabled
        return nil
      end

      project_name = project['name']
    else
      project_name = '-'
    end

    function_name = nil
    feature_detail = nil

    name_key = "ipf_logger_#{function_data['controller']}_#{function_data['action']}"
    unless function_data['key_name_proc'].nil?
      postfix = send(function_data['key_name_proc'])

      if postfix.nil?
        return ['-', '-', project_name]
      end

      name_key.concat "_#{postfix}"
    end

    translate_options = {:locale => @@log_locale, :fallback => false}
    unless function_data['replace_rules'].nil?
      function_data['replace_rules'].each do |key, rule|
        translate_options.merge! key.to_sym => convert_replace_string(option_params[rule.to_sym])
      end
    end

    function_name_options = translate_options.clone
    feature_detail_options = translate_options.clone

    function_name = t("#{name_key}_function", function_name_options)
    feature_detail = t("#{name_key}_detail", feature_detail_options)

    return [function_name, feature_detail, project_name]
  end

  #
  #===Get key for exporting
  #
  def format_issues_index
    if params[:format].nil?
      # issues
      "index"
    else
      x = params[:format].downcase
      if (x == "xlsx") || (x == "csvx")
        # work time export
        "wt_export"
      else
        # issues export
        "export"
      end
    end
  end

  def work_time_show
    if params.key?("new_time_entry")
      "update"
    else
      "index"
    end
  end

  #
  #===Get project data
  #
  def get_project(option_params)
    if params.key?(:project_id)
      Project.find(params[:project_id])
    else
      nil
    end
  end

  #
  #===Get ticket's project data
  #
  def get_issues_project(option_params)
    begin
      issue = Issue.find(:first, :conditions => ["id IN (?)", option_params[:ids]])
      (issue.nil?) ? nil: Project.find(issue['project_id'])
    rescue => err
      nil
    end
  end

  #
  #===Check module enables in this project.
  #
  def check_module_enabled?(project_id)
    module_enabled = EnabledModule.find(:all, :conditions => ["project_id = ? and name = ?", project_id, 'ipf_log'])
    (module_enabled.length > 0) ? true: false;
  end

  #
  #===Convert to string for log
  #
  def convert_replace_string(value)
    if value.is_a?(Array)
      value.join(",")
    elsif value.is_a?(Hash)
      value.inspect
    else
      value.to_s
    end
  end
end
