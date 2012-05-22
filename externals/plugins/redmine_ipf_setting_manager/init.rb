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

Dispatcher.to_prepare :redmine_ipf_setting_manager do
  require_dependency 'user'
  User.send :include, IpfUserHtdigestPatch
end

Redmine::Plugin.register :redmine_ipf_setting_manager do
  name 'IPF Setting Manager'
  author 'Information-technology Promotion Agency, Japan'
  description 'This is a plugin of IPF Setting Manager'
  version '1.0.0'
  url 'http://www.ipa.go.jp/'
  author_url 'http://www.ipa.go.jp/'
  

  # create and repository menu
  menu :admin_menu , :redmine_ipf_repository, { :controller => 'ipf_repository', :action => 'index' },:caption => :ipf_sm_repository_menu

  # backup menu
  menu :admin_menu , :redmine_ipf_backup, { :controller => 'ipf_backup', :action => 'index' },:caption => :ipf_sm_backup_menu


  # settings
  if RUBY_PLATFORM =~ /mswin(?!ce)|mingw|cygwin|bccwin/
    settings :default => {
       'ipf_backup_script' => 'c:/ipftools/script/ipf_backup',
       'ipf_repository_script' => 'c:/ipftools/script/ipf_repository',
       'ipf_scm' => 'Subversion',
       'ipf_htdigest_file' => 'c:/ipftools/var/htdigest.txt'
     }, :partial => 'settings/ipf_setting_manager_settings'
  else
    settings :default => {
       'ipf_backup_script' => '/usr/lib/ipftools/script/ipf_backup',
       'ipf_repository_script' => '/usr/lib/ipftools/script/ipf_repository',
       'ipf_scm' => 'Subversion',
       'ipf_htdigest_file' => '/usr/lib/ipftools/var/htdigest.txt'
     }, :partial => 'settings/ipf_setting_manager_settings'
  end


end
