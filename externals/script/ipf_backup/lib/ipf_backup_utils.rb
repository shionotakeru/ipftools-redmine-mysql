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

require "rubygems"
require 'zipruby'

#
#= backup script utilities
#
# This is the utilitiy module for backup.
#
module IpfBackupUtils

  #===ZIP compression
  #
  def make_zip(target, zippath, rootdir)
    Dir::chdir(rootdir) do
      Zip::Archive.open(zippath, Zip::CREATE) do |arc|   
      if File.directory?(target)      
        target = (target + "/").sub("//", "/")      
        Dir::chdir(target) do      
           Dir.glob("**/*") do |file|         
              if File.directory?(file)             
                  arc.add_dir(target+file)         
              else            
                  arc.add_file(target+file, file)          
              end      
            end      
          end   
        else      
          arc.add_file(target)   
        end 
      end
    end
  end  
  
  #==#ZIP comment add
  #
  def add_zip_comment(zipfile, comment)
    Zip::Archive.open(zipfile) do |ar|
      ar.comment = comment
    end 
  end

  #===create PostgreSQL 'pg_dump' command 
  #
  def get_pgdump_cmd(pgdump_path, host, port, user, database, dumpfile)
    cmd_pg_dump = File.join((pgdump_path),"pg_dump") + " -c -h " + host + " -p " + port.to_s + " -U " + user + " " + database + " > " + dumpfile
  end

  #===convert the repository path
  #
  def convert_repository_path(path)
    if File.directory?(path) then
      return path
    else
      if /^file:\/\/\// =~ path
        return path.sub("file:///","") 
      else 
        return path 
      end
    end 
  end

end