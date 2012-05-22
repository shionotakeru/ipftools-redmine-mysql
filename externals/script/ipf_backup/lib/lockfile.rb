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
#= Lock file class
#
class Lockfile
  
  # initializing
  def initialize(filepath)
    @lock_file_path = filepath

    at_exit do
      unlock
    end
  end

  # create lock file 
  def self.create(filepath)
    obj = Lockfile.new(filepath)

    if block_given?
      begin
        obj.lock
        yield obj
      ensure
        obj.unlock
      end
    end

    obj
  end

  # to lock 
  def lock
    if @lock_obj.nil?
      f = File.new(@lock_file_path, "w")
      if f.flock(File::LOCK_EX | File::LOCK_NB)
        @lock_obj = f
        @locked_status = true
      else
        @locked_status = false
      end
    else
      # already locked
    end

    @locked_status
  end

  # to unlock
  def unlock
    unless @lock_obj.nil?
      begin
        @lock_obj.flock(File::LOCK_UN)
        @lock_obj.close
      rescue
      end

      if File.exist?(@lock_file_path)
        File.unlink @lock_file_path
      end
      @locked_status = false
      @lock_obj = nil
    end
  end

  # Check locked
  def locked?
    @locked_status
  end
  
end
