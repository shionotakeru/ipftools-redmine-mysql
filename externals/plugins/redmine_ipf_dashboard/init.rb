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

require 'ipf_dashboard_menu_listener'

Redmine::Plugin.register :redmine_ipf_dashboard do
  name 'IPF Dashboard'
  author 'Information-technology Promotion Agency, Japan'
  description 'Show IPF graph dashboard.'
  version '1.0.0'
  url 'http://www.ipa.go.jp/'
  author_url 'http://www.ipa.go.jp/'

  project_module :ipf_graph do
    permission :ipf_analyze, :ipf_show_graphs => [:index], :require => :member
  end

  menu :project_menu, :ipf_dashboard, {:controller => 'ipf_show_graphs', :action => 'index'}, :caption => :ipf_dashboard_menu_title, :after => :files, :param => :project_id, :if => Proc.new { |proj| IpfDashboardMenuListener::MenuListener.allow_show_dashboard?(proj) }

  settings :default => {
    'ipf_analyze_url'         => '',
    'ipf_dashboard_hash_key'  => 'o@gytsvtrf,omr',
  }, :partial => 'settings/ipf_dashboard_settings'
end

