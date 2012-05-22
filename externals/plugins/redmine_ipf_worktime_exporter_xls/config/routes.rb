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
  map.with_options :controller => 'issues' do |issues_routes|
    issues_routes.with_options :conditions => {:method => :get} do |issues_views|
      issues_views.connect "issues/ipf_wt_exp_xls_action", :action => "ipf_wt_exp_xls_action"
      issues_views.connect "projects/:project_id/issues/ipf_wt_exp_xls_action", :action => "ipf_wt_exp_xls_action"
    end
  end
end
