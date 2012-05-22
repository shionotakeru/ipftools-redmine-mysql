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

class MspTask
  attr_accessor :task_id
  attr_accessor :name
  attr_accessor :resource
  attr_accessor :start_date
  attr_accessor :finish_date
  attr_accessor :create_date
  attr_accessor :parent
  attr_accessor :create
  attr_accessor :outline_level
  attr_accessor :outline_number
  attr_accessor :wbs

  def create?
    @create
  end
end
