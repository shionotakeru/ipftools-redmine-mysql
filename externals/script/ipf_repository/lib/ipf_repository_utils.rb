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
#= backup script utilities
#
# This is the utilitiy module for backup.
#
module IpfRepositoryUtils

  #===create Subversion repository-create command 
  #
  def get_svnrepos_create_cmd(svnadmin_path,repository_path)
    cmd = [
      File.join(svnadmin_path,"svnadmin") + " create " + repository_path
    ]
  end

  #===create Git bare-repository-create command 
  #
  def get_gitrepos_create_cmd(git_path, repository_path)
    cmd = [
      File.join(git_path,"git") + " init --bare " + repository_path,
      File.join(git_path,"git") + " --git-dir=" + repository_path + " update-server-info"  
    ]
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
    
  #===convert repository path, "xxx.." => "file:///xxx.." (only Subversion)
  #
  def convert_url(url, type)
    if IpfRepositoryEnv::SCM_SVN == type then
      "file:///" + url
    else
      url
    end
  end

end