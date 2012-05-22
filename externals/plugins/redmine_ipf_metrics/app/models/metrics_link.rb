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

class MetricsLink < ActiveRecord::Base
  unloadable
#  belongs_to :metrics
#  belongs_to :tracker
#  belongs_to :metrics, :class_name => "Metrics"
#  belongs_to :tracker, :class_name => "Tracker"
  belongs_to :metrics, :class_name => "Metrics", :foreign_key => "metrics_id"
  belongs_to :tracker, :class_name => "Tracker", :foreign_key => "tracker_id"
end
