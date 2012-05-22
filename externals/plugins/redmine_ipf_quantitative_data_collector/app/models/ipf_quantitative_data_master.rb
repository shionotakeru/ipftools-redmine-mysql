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
#=Quantitative Data Collecter Item master class
#
class IpfQuantitativeDataMaster < ActiveRecord::Base
  unloadable

  #
  #===Get the Batch Id for project management PF data collect
  #
  def self.get_pf_batch_id
    find(:all, :select => "proc_id, batch_id", :conditions => ['collect_type = 0'])
  end

  #
  #===Get the Batch Id for graph data collect
  #
  def self.get_graph_batch_id
    find(:all, :select => "proc_id, batch_id", :conditions => ['collect_type = 1'])
  end

  #
  #===Get batch Id
  #
  #====Arguments
  #_collect_type_ :: 0 is project management PF data, 1 is graph data
  #_proc_id_ :: Number which is argument for batch program
  #
  def self.get_batch_id(collect_type, proc_id)
    data = first(:select => "batch_id", :conditions => ['proc_id = ? and collect_type = ?', proc_id, collect_type])
    return data[:batch_id]
  end

  #
  #===Get Item list for project management PF data collecting
  #
  def self.get_pf_data_table
    find(
      :all,
      :conditions => ['collect_type = 0'],
      :order => "proc_id")
  end

  #
  #===Get Item list for graph data collecting
  #
  def self.get_graph_data_table
    find(
      :all,
      :conditions => ['collect_type = 1'],
      :order => "proc_id")
  end
end
