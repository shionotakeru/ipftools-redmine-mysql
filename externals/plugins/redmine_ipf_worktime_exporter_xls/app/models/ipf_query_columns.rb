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

class IpfQueryColumn
  attr_accessor :name, :sortable, :groupable, :default_order
  include Redmine::I18n

  def initialize(name, options={})
    self.name = name
    self.sortable = options[:sortable]
    self.groupable = options[:groupable] || false
    if groupable == true
      self.groupable = name.to_s
    end
    self.default_order = options[:default_order]
    @caption_key = options[:caption] || "field_time_entry_#{name}"
  end

  def caption
    l(@caption_key)
  end

  # Returns true if the column is sortable, otherwise false
  def sortable?
    !sortable.nil?
  end

  def value(issue)
    issue.send name
  end

  def css_classes
    name
  end
end
