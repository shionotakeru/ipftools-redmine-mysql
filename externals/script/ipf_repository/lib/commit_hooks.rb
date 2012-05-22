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
#= SCM Commit Hooks Class
#
class CommitHooks
  
  # commit hook file name
  WINDOWS_SVN_HOOKS = "post-commit.bat" 
  WINDOWS_GIT_HOOKS = "post-receive" 
  LINUX_SVN_HOOKS = "post-commit" 
  LINUX_GIT_HOOKS = "post-receive" 
  
  # template path
  WINDOWS_SVN_TEMPLATE_PATH = "windows/svn/" + WINDOWS_SVN_HOOKS
  WINDOWS_GIT_TEMPLATE_PATH = "windows/git/" + WINDOWS_GIT_HOOKS 
  LINUX_SVN_TEMPLATE_PATH = "linux/svn/" + LINUX_SVN_HOOKS 
  LINUX_GIT_TEMPLATE_PATH = "linux/git/" + LINUX_GIT_HOOKS 
  
  # initializing
  def initialize(target_scm, repository_path, project_identifier, batch_path)
    @target_scm = target_scm
    @repository_path = repository_path
    @project_identifier = project_identifier
    @batch_path = batch_path
    @template_path = get_template_path(@target_scm)
    @commit_hook_path = get_commit_hooks_path(@target_scm)
  end

  #===To determine whether platform is Windows 
  #
  def windows?
    "Windows_NT" == ENV['OS'] ? true : false
  end
  
  #===Get path of template 
  #
  def get_template_path(target_scm)
    result = File.expand_path("../../template/hooks",__FILE__)  
    if windows?
      if "Subversion" == @target_scm
        result = File.join(result, WINDOWS_SVN_TEMPLATE_PATH) 
      else
        result = File.join(result, WINDOWS_GIT_TEMPLATE_PATH) 
      end
    else
      if "Subversion" == @target_scm
        result = File.join(result, LINUX_SVN_TEMPLATE_PATH) 
      else
        result = File.join(result, LINUX_GIT_TEMPLATE_PATH) 
      end
    end
    result
  end
  
  #===Get path of template 
  #
  def get_commit_hooks_path(target_scm)
    result = File.join(@repository_path,"hooks")
    if windows?
      if "Subversion" == @target_scm
        result = File.join(result, WINDOWS_SVN_HOOKS) 
      else
        result = File.join(result, WINDOWS_GIT_HOOKS) 
      end
    else
      if "Subversion" == @target_scm
        result = File.join(result, LINUX_SVN_HOOKS) 
      else
        result = File.join(result, LINUX_GIT_HOOKS) 
      end
    end
    result
  end
  
  # create commit hooks file
  def create
    # template copy
    FileUtils.cp(@template_path, @commit_hook_path)
    
    # permission
    FileUtils.chmod(0755, @commit_hook_path)
    
    # Rewrite project identifiers 
    File.open(@commit_hook_path , "r+") {|f|
      f.flock(File::LOCK_EX)
      body = f.read
      body = body.gsub("@PROJECT_IDENTIFIER", @project_identifier) 
      body = body.gsub("@BATCH_PATH", @batch_path)
      f.rewind
      f.puts body
      f.truncate(f.tell)
    }
  end
  
end
