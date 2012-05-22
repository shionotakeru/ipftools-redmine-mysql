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

Redmine::Plugin.register :IpfWorktimeCsvImporter do
  name 'IPF TimeEntry CSV Import' 
  author 'Information-technology Promotion Agency, Japan'
  description 'Time Entry import(CSV) plugin for Redmine.'
  version '1.0.0'
  url 'http://www.ipa.go.jp/'
  author_url 'http://www.ipa.go.jp/'

  project_module :ipf_worktime_csv_importer do
    permission :ipf_exec_worktime_csv_importer, {:IpfWorktimeCsvImporter => [:index, :match]}
  end
  menu :project_menu, :ipf_worktime_csv_importer, { :controller => 'IpfWorktimeCsvImporter', :action => 'index' }, :caption => :ipf_wt_imp_csv_label_ipf_csv_importer, :before => :work_time, :param => :project_id

  ActionController::Routing::Routes.draw do |map|
    map.connect 'projects/:project_id/ipf_worktime_csv_importer/:action', :controller => 'IpfWorktimeCsvImporter'
  end
end
