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

require_dependency 'projects_helper'

module SettingsProjectsHelperPatch

    include IpfMetricsHelper

    #
    #=== The addition of the method to method chain 
    #
    #_base_ :: base 
    #
    def self.included(base)
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)
        base.class_eval do
            unloadable
            alias_method_chain :project_settings_tabs, :hook
        end
    end

    module ClassMethods
    end

    module InstanceMethods

        #
        #=== Setting screen tab addition processing 
        #=== (Metrics & Graph Pattern) 
        #
        def project_settings_tabs_with_hook
            tabs = project_settings_tabs_without_hook
            if permission(User.current.id, @project.id, "ipf_metrics", "ipf_exec_metrics_project")
              tabs << {:name => 'ipfmetricsproject', :partial => 'settings/ipfmetricsproject', :label => :title_ipf_metrics_tab}
            end
            if permission(User.current.id, @project.id, "ipf_graph_pattern", "ipf_exec_graph_pattern_project")
              tabs << {:name => 'ipfgraphpatternproject', :partial => 'settings/ipfgraphpatternproject', :label => :title_ipf_graph_pattern_tab}
            end
            return tabs
        end

    end

end
