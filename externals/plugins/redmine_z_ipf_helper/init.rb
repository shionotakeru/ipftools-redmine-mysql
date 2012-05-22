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

require 'redmine'
require 'dispatcher'
require 'ipf_wt_exp_xls'
require 'ipf_wt_exp_xls_patch'
require 'ipf_wt_exp_csv'
require 'ipf_wt_exp_csv_patch'
require 'ipf_exp_xml'
require 'ipf_exp_xml_patch'
require 'ipf_import_menu_item'

Dispatcher.to_prepare :ipf_exp_xml do
  
  Mime::Type.register('application/xml', :xml, %w(application/xml)) unless defined? Mime::XML

  unless IssuesController.included_modules.include? IpfExpXMLPatch
    IssuesController.send(:include, IpfExpXMLPatch)
  end

end

unless Redmine::Plugin.registered_plugins.keys.include?(:ipf_exp_xml)
  Redmine::Plugin.register :ipf_exp_xml do
    name 'IPF Issues XML export'
    author 'Information-technology Promotion Agency, Japan'
    description 'Issues export(MS Project) plugin for Redmine.'
    version '1.0.0'
    url 'http://www.ipa.go.jp/'
    author_url 'http://www.ipa.go.jp/'

    settings(:partial => 'settings/ipf_exp_xml_settings',
             :default => {
               'issues_limit' => '0',
               'export_name' => 'issues_xml_export'
             })

    requires_redmine :version_or_higher => '1.0.1'

  end

  require 'ipf_exp_xml_hooks'

end

Dispatcher.to_prepare :ipf_wt_exp_csv do
  
  Mime::Type.register('text/comma-separated-values', :CSV, %w(text/comma-separated-values)) unless defined? Mime::CSV

  unless IssuesController.included_modules.include? IpfWtExpCSVPatch
    IssuesController.send(:include, IpfWtExpCSVPatch)
  end

end

unless Redmine::Plugin.registered_plugins.keys.include?(:ipf_wt_exp_csv)
  Redmine::Plugin.register :ipf_wt_exp_csv do
    name 'IPF Time Entry CSV export'
    author 'Information-technology Promotion Agency, Japan'
    description 'Time Entry export(CSV) plugin for Redmine.'
    version '1.0.0'
    url 'http://www.ipa.go.jp/'
    author_url 'http://www.ipa.go.jp/'

    settings(:partial => 'settings/ipf_wt_exp_csv_settings',
             :default => {
               'issues_limit' => '0',
               'export_name' => 'timeentry_csv_export'
             })

    requires_redmine :version_or_higher => '1.0.1'

  end

  require 'ipf_wt_exp_csv_hooks'

end

Dispatcher.to_prepare :ipf_wt_exp_xls do
  
  Mime::Type.register('application/vnd.ms-excel', :xls, %w(application/vnd.ms-excel)) unless defined? Mime::XLS

  unless IssuesController.included_modules.include? IpfWtExpXLSPatch
    IssuesController.send(:include, IpfWtExpXLSPatch)
  end

end

unless Redmine::Plugin.registered_plugins.keys.include?(:ipf_wt_exp_xls)
  Redmine::Plugin.register :ipf_wt_exp_xls do
    name 'IPF Time Entry XLS export'
    author 'Information-technology Promotion Agency, Japan'
    description 'Time Entry export(XLS) plugin for Redmine.'
    version '1.0.0'
    url 'http://www.ipa.go.jp/'
    author_url 'http://www.ipa.go.jp/'

    settings(:partial => 'settings/ipf_wt_exp_xls_settings',
             :default => {
               'group' => '0',
               'generate_name' => '1',
               'issues_limit' => '0',
               'export_name' => 'timeentry_xls_export'
             })

    requires_redmine :version_or_higher => '1.0.1'

  end

  require 'ipf_wt_exp_xls_hooks'

end

Redmine::Plugin.register :Z_IPF_MENU_SORT do
  name 'IPF Helper'
  author 'Information-technology Promotion Agency, Japan'
  description 'IPF Plugin Helper plugin for Redmine.'
  version '1.0.0'
  url 'http://www.ipa.go.jp/'
  author_url 'http://www.ipa.go.jp/'

  project_module :ipf_graph do
    permission :ipf_graph_m02, :ipf => :graph_m02
    permission :ipf_graph_m03, :ipf => :graph_m03
    permission :ipf_graph_s01, :ipf => :graph_s01
    permission :ipf_graph_s02, :ipf => :graph_s02
    permission :ipf_graph_s03, :ipf => :graph_s03
    permission :ipf_graph_s04, :ipf => :graph_s04
    permission :ipf_graph_s05, :ipf => :graph_s05
    permission :ipf_graph_s06, :ipf => :graph_s06
    permission :ipf_graph_s07, :ipf => :graph_s07
    permission :ipf_graph_s08, :ipf => :graph_s08
    permission :ipf_graph_s09, :ipf => :graph_s09
    permission :ipf_graph_s10, :ipf => :graph_s10
    permission :ipf_graph_s11, :ipf => :graph_s11
    permission :ipf_graph_s12, :ipf => :graph_s12
    permission :ipf_graph_s13, :ipf => :graph_s13
    permission :ipf_graph_s14, :ipf => :graph_s14
    permission :ipf_graph_s15, :ipf => :graph_s15
  end

  project_module :ipf_metrics do
    permission :ipf_exec_metrics_project, :ipf_metrics => :index
  end

  project_module :ipf_graph_pattern do
    permission :ipf_exec_graph_pattern_project, :ipf_graph_pattern => :index
  end

  Redmine::MenuManager.map :project_menu do |menu|
    menu.delete :importer
    menu.delete :ipf_xls_importer
    menu.delete :ipf_worktime_csv_importer
    menu.delete :ipf_worktime_xls_importer
    menu.delete :msprojects

    import_menu = IpfImportMenuItem.new

    permission :import_menu, {:pulldown => :action}, :public => true
    menu.push :import_menu, {:controller => 'pulldown', :action => 'action'}, :caption => :label_import_menu, :before => :work_time, :html => {:class => 'ipf-has-children', :onclick => 'return false;'}, :children => import_menu, :if => Proc.new { |proj| IpfImportMenuItem.enable_import_menu?(proj) }
  end

end
