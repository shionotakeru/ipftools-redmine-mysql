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

Redmine::Plugin.register :redmine_ipf_quantitative_data_collector do
  name 'IPF Quantitative Data Collector'
  author 'Information-technology Promotion Agency, Japan'
  description 'This plugin is execution screen for Graph Data and/or Project PF Data Collect.'
  version '1.0.0'
  url 'http://www.ipa.go.jp/'
  author_url 'http://www.ipa.go.jp/'

  project_module :ipf_quantitative_data_collector do
    permission :ipf_exec_quantitative_data_collector, :ipf_data_collect => [:index, :execute, :check], :require => :member
  end

  # insert menu item to project menubar
  menu :project_menu, :ipf_quantitative_data_collector, {:controller => 'ipf_data_collect', :action => 'index'}, :caption => :ipf_quantitative_data_collector_menu_title, :after => :files, :param => :project_id

  # this plugin's settings
  if RUBY_PLATFORM =~ /mswin(?!ce)|mingw|cygwin|bccwin/
    settings :default => {
      'ipf_qdc_check_interval' =>   60000,
      'ipf_qdc_batch_path' =>       'C:/IPFTools/batch',
      'ipf_qdc_batch_log_path' =>   'C:/IPFTools/data/batch',
      'ipf_qdc_lock_lifetime' =>    5
    }, :partial => 'settings/ipf_quantitative_data_collector_settings'
  else
    settings :default => {
      'ipf_qdc_check_interval' =>   60000,
      'ipf_qdc_batch_path' =>       '/usr/lib/ipftools/batch',
      'ipf_qdc_batch_log_path' =>   '/usr/lib/ipftools/data/batch',
      'ipf_qdc_lock_lifetime' =>    5
    }, :partial => 'settings/ipf_quantitative_data_collector_settings'
  end
end
