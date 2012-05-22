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

require 'rubygems'
require 'pg'

#
#= restore script utilities
#
module IpfRestoreUtils

  #
  #===find command
  #
  def find_command(*commands)
    dirs_on_path = ENV['PATH'].to_s.split(File::PATH_SEPARATOR)
    commands += commands.map { |cmd| "#{cmd}.exe" } if self.win32?

    full_path_command = nil
    found = commands.detect do |cmd|
      dir = dirs_on_path.detect do |path|
        full_path_command = File.join(path, cmd)
        File.executable?(full_path_command)
      end
    end
    found ? full_path_command: nil
  end

  #
  #===check os type is win32
  #
  def win32?
    (RUBY_PLATFORM.downcase =~ /mswin(?!ce)|mingw|cygwin|bccwin/)
  end

  #
  #===convert the repository path
  #
  def convert_repository_path(path)
    if File.directory?(path)
      return path
    else
      if /^file:\/\/\// =~ path
        return path.sub("file:///", "")
      end
    end
  end
end
