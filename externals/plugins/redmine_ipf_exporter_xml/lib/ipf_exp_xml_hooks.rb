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


class IpfExpXMLHook < Redmine::Hook::ViewListener
  #
  #=== A link addition on the issues index button 
  #
  #_context_ :: context 
  #
  def view_issues_index_bottom(context={})
    if context[:query].valid? && !context[:issues].empty?
      ret_str =''
      ret_str << stylesheet_link_tag("ipf_exp_xml.css", :plugin => "redmine_ipf_exporter_xml", :media => "screen")
      ret_str << '<p class="other-formats">' << l(:label_ipf_exp_xml_format)
      ret_str << content_tag('span', link_to(l(:label_ipf_exp_xml_format_quick),
                                            { :controller => 'issues', :action => 'index', :project_id => context[:project], :format => 'xmlx' },
                                            { :class => 'xml', :rel => 'nofollow', :title => l(:label_ipf_exp_xml_format_quick_tooltip) }))
      ret_str << content_tag('span', link_to(l(:label_ipf_exp_xml_format_detailed),
                                            { :controller => 'issues', :action => 'ipf_exp_xml_action', :project_id => context[:project] },
                                            { :class => 'xmlf', :title => l(:label_ipf_exp_xml_format_detailed_tooltip) }))
      ret_str << '</p>'

      return ret_str
    end
  end
end
