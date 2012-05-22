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

ActionController::Routing::Routes.draw do |map|
  map.connect '/ipfmetricsglobal', :controller => 'IpfMetricsGlobal', :action => 'index'
  map.connect '/ipfgraphpatternglobal', :controller => 'IpfGraphPatternGlobal', :action => 'index'
  map.connect '/ipfmetricsglobal/entry', :controller => 'IpfMetricsGlobal', :action => 'entry'
  map.connect '/ipfmetricsproject/entry', :controller => 'IpfMetricsProject', :action => 'entry'
  map.connect '/ipfgraphpatternglobal/new', :controller => 'IpfGraphPatternGlobal', :action => 'new'
  map.connect '/ipfgraphpatternglobal/new_entry', :controller => 'IpfGraphPatternGlobal', :action => 'new_entry'
  map.connect '/ipfgraphpatternglobal/update', :controller => 'IpfGraphPatternGlobal', :action => 'update'
  map.connect '/ipfgraphpatternglobal/update_entry', :controller => 'IpfGraphPatternGlobal', :action => 'update_entry'
  map.connect '/ipfgraphpatternglobal/delete', :controller => 'IpfGraphPatternGlobal', :action => 'delete'
  map.connect '/ipfgraphpatternglobal/delete_entry', :controller => 'IpfGraphPatternGlobal', :action => 'delete_entry'
  map.connect '/ipfgraphpatternproject/new/:project_id', :controller => 'IpfGraphPatternProject', :action => 'new'
  map.connect '/ipfgraphpatternproject/new_entry', :controller => 'IpfGraphPatternProject', :action => 'new_entry'
  map.connect '/ipfgraphpatternproject/update', :controller => 'IpfGraphPatternProject', :action => 'update'
  map.connect '/ipfgraphpatternproject/update_entry', :controller => 'IpfGraphPatternProject', :action => 'update_entry'
  map.connect '/ipfgraphpatternproject/delete', :controller => 'IpfGraphPatternProject', :action => 'delete'
  map.connect '/ipfgraphpatternproject/delete_entry', :controller => 'IpfGraphPatternProject', :action => 'delete_entry'
  map.connect '/ipfdashboard', :controller => 'IpfDashboard', :action => 'index'
  map.connect '/ipfdashboard/list', :controller => 'IpfDashboard', :action => 'list'
  map.connect '/ipfdashboard/setup', :controller => 'IpfDashboard', :action => 'setup'
end
