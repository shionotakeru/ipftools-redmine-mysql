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

require 'yaml'
require 'tmpdir'

#
#= Restore Environment
#
class IpfRestoreEnv
  # Extract temporary dir
  attr_reader :restore_temp_dir

  # Redmine DB settings
  attr_reader :redmine_db_host
  attr_reader :redmine_db_port
  attr_reader :redmine_db_database
  attr_reader :redmine_db_username
  attr_reader :redmine_db_password

  # Redmine attachment file
  attr_reader :redmine_append_path

  # IPF DB settings
  attr_reader :ipf_db_host
  attr_reader :ipf_db_port
  attr_reader :ipf_db_database
  attr_reader :ipf_db_username
  attr_reader :ipf_db_password

  def initialize
    # setting file read
    settings = read_restore_settings

    @redmine_db_host = settings["IpfRestore"]["Redmine"]["DB"]["host"]
    @redmine_db_port = settings["IpfRestore"]["Redmine"]["DB"]["port"]
    @redmine_db_database = settings["IpfRestore"]["Redmine"]["DB"]["database"]
    @redmine_db_username = settings["IpfRestore"]["Redmine"]["DB"]["username"]
    @redmine_db_password = settings["IpfRestore"]["Redmine"]["DB"]["password"]
    @redmine_append_path = settings["IpfRestore"]["Redmine"]["Appended"]["path"]

    @ipf_db_host = settings["IpfRestore"]["IPF_DB"]["host"]
    @ipf_db_port = settings["IpfRestore"]["IPF_DB"]["port"]
    @ipf_db_database = settings["IpfRestore"]["IPF_DB"]["database"]
    @ipf_db_username = settings["IpfRestore"]["IPF_DB"]["username"]
    @ipf_db_password = settings["IpfRestore"]["IPF_DB"]["password"]

    @restore_temp_dir = File.join(Dir.tmpdir, ".ipf_restore.#{$$}")
  end

  private

  def read_restore_settings
    YAML.load_file(File.expand_path("../../config/restore_settings.yml", __FILE__))
  end
end
