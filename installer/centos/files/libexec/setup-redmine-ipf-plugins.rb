#   <Quantitative project management tool.>
#
#   Copyright (C) 2012 IPA, Japan.
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.

IPFTOOLS_ROOT = ENV["IPFTOOLS_ROOT"] || raise
IPFTOOLS_SCM = ENV["IPFTOOLS_SCM"] || raise
IPFTOOLS_DATA_DIR = ENV["IPFTOOLS_DATA_DIR"] || raise


def update_settings(plugin, new_values = {})
  key = "plugin_#{plugin}"
  unless Setting.respond_to?(key)
    warn "#{plugin}: no plugin."
    return
  end
  unless new_values.empty?  
    Setting[key] = Setting[key].merge(new_values) 
    puts "#{plugin}: update settings."
  end
end


update_settings :redmine_ipf_setting_manager, {
  'ipf_backup_script'		=> File.expand_path('script/ipf_backup', IPFTOOLS_ROOT),
  'ipf_repository_script'	=> File.expand_path('script/ipf_repository', IPFTOOLS_ROOT),
  'ipf_scm'			=> case IPFTOOLS_SCM
                                   when 'svn'
                                     'Subversion'
                                   when 'git'
                                     'Git'
                                   end,
  'ipf_htdigest_file'		=> File.expand_path('htdigest.txt', IPFTOOLS_DATA_DIR),
}


update_settings :redmine_ipf_log


update_settings :redmine_ipf_quantitative_data_collector, {
  'ipf_qdc_batch_path'		=> File.expand_path('batch', IPFTOOLS_ROOT),
  'ipf_qdc_batch_log_path'	=> File.expand_path('redmine', IPFTOOLS_DATA_DIR),
}


update_settings :redmine_ipf_dashboard, {
  'ipf_analyze_url'		=> '/birt-viewer/dashboard',
}

Setting.date_format = '%Y-%m-%d'
puts "date_format: update settings."

Setting.default_language = 'ja'
puts "default_language: update settngs."
