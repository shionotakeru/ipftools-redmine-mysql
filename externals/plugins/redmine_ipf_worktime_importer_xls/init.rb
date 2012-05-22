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

Redmine::Plugin.register :IpfWorktimeXlsImporter do
  name 'IPF TimeEntry XLS Import' 
  author 'Information-technology Promotion Agency, Japan'
  description 'Time Entry import(XLS) plugin for Redmine.'
  version '1.0.0'
  url 'http://www.ipa.go.jp/'
  author_url 'http://www.ipa.go.jp/'

  project_module :ipf_worktime_xls_importer do
    permission :ipf_exec_worktime_xls_importer, :IpfWorktimeXlsImporter => [:index, :select, :match] 
  end
  menu :project_menu, :ipf_worktime_xls_importer, { :controller => 'IpfWorktimeXlsImporter', :action => 'index' }, :caption => :ipf_wt_imp_xls_label_ipf_xls_importer, :before => :work_time, :param => :project_id

  ActionController::Routing::Routes.draw do |map|
    map.connect 'projects/:project_id/ipf_worktime_xls_importer/:action', :controller => 'IpfWorktimeXlsImporter'
  end
end
