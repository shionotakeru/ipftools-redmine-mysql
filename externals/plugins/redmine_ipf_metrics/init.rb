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

Dispatcher.to_prepare :ipf_metrics do
    unless ProjectsHelper.included_modules.include?(SettingsProjectsHelperPatch)
        ProjectsHelper.send(:include, SettingsProjectsHelperPatch)
    end
    unless ProjectsController.included_modules.include?(ProjectsControllerPatch)
        ProjectsController.send(:include, ProjectsControllerPatch)
    end
end

Redmine::Plugin.register :ipf_metrics do
  name 'IPF Metrics plugin' 
  author 'Information-technology Promotion Agency, Japan'
  description 'Metrics information setting plugin for Redmine.'
  version '1.0.0'
  url 'http://www.ipa.go.jp/'
  author_url 'http://www.ipa.go.jp/'

  menu :admin_menu , :ipf_metrics_global, { :controller => 'IpfMetricsGlobal', :action => 'index' }, :caption => :title_ipf_metrics_menu
  menu :admin_menu , :ipf_graph_pattern_global, { :controller => 'IpfGraphPatternGlobal', :action => 'index' }, :caption => :title_ipf_graph_pattern_menu
  menu :account_menu , :ipf_dashboard, { :controller => 'IpfDashboard', :action => 'index' }, :caption => :title_ipf_dashboard_menu

end
