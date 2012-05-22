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

require 'openssl'
require 'base64'
require 'pp'

module IpfDashboardMenuListener

  #
  #=IPF Dashboard, Menu hook class
  #
  class MenuListener < Redmine::Hook::ViewListener

    #
    #===check show dashboard permission
    #
    def self.allow_show_dashboard?(project)
      User.current.allowed_to?(:ipf_analyze, project)
    end

    #
    #===Rewrite redmine header html
    #
    def view_layouts_base_html_head(context)
      url = Setting.plugin_redmine_ipf_dashboard['ipf_analyze_url']

      project = context[:project]
      if project.nil?
        return
      end

      user = User.current
      return if user.nil?

      # get graph dashboard pattern jsp
      jsp_path = ''
      dashboard_config = Dashboard.find(:first, :select => 'graph_pattern_id', :conditions => ['project_id = ? and user_id = ?', project[:id], user[:id]])
      unless dashboard_config.nil?
        unless dashboard_config['graph_pattern_id'].nil?
          graph_pattern = GraphPattern.find(dashboard_config['graph_pattern_id'])
          unless graph_pattern.nil?
            jsp_path = graph_pattern[:jsp]
          end
        end
      end

      key = Setting.plugin_redmine_ipf_dashboard['ipf_dashboard_hash_key']

      user_base64 = Base64.encode64(user.id.to_s).strip
      timestamp = Time.now.to_i.to_s

      params = "PROJECT_ID=#{project[:id]}&USER_ID=#{user_base64}&JSP_PATH=#{jsp_path}&t=#{timestamp}"

      hmac = OpenSSL::HMAC.new(key, OpenSSL::Digest::SHA1.new)
      hmac.update("#{params}")
      hexdigest = hmac.hexdigest

      params = "#{params}&digest=#{hexdigest}"
      url = "#{url}?#{params}"

      openurl = "javascript:void(window.open('#{url}','mainFrame','menubar=yes,toolbar=yes,location=yes,resizable=yes,scrollbars=yes'));"

      Redmine::MenuManager.map(:project_menu).find(:ipf_dashboard).html_options[:href] = openurl
      nil
    end
  end
end
