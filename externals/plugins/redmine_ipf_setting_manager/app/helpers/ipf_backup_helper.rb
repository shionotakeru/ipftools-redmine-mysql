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

#
#=Backup View Helper
#
module IpfBackupHelper

  #===date format
  #
  #  datetime => YYYY/MM/DD HH:MM
  #  
  def format_datetime(datetime)
    return "" unless datetime
    datetime.strftime("%Y/%m/%d %H:%M:%S")
  end
  
  #===get backup target name
  #  
  def get_target_name(target)
    return '' unless target
    if target == 0 then
      l(:ipf_sm_backup_all)
    else
      l(:ipf_sm_backup_redmine_and_scm)
    end
  end
  
end