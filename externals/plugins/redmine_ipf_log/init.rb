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

Dispatcher.to_prepare :redmine_ipf_log do
  require_dependency 'application_controller'
  ApplicationController.send :include, IpfApplicationControllEx
end

Redmine::Plugin.register :redmine_ipf_log do
  name 'IPF Log'
  author 'Information-technology Promotion Agency, Japan'
  description 'This plugin is outputs operation logs'
  version '1.0.0'
  url 'http://www.ipa.go.jp/'
  author_url 'http://www.ipa.go.jp/'

  project_module :ipf_log do
    permission :ipf_logging, {}, :public => true
  end

  settings :default => {
    'ipf_log_file' =>     'ipf_operation.log',
    'ipf_log_interval' => 'daily',
    'ipf_log_locale' =>   'ja'
  }, :partial => 'settings/ipf_log_settings'
end
