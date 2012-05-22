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

class IpfImportMenuItem
  def call(project)
    menu_items = []

    IpfImportMenuItem.import_menu_items(project).each do |item|
      menu_items.push Redmine::MenuManager::MenuItem.new(item[:item_name], item[:url], :caption => item[:caption])
    end

    menu_items
  end

  def self.enable_import_menu?(project)
    # logged on members only
    return false unless User.current.logged?

    self.import_menu_items(project).each do |item|
      # if project has any menu allowed one, returns true
      return true if User.current.allowed_to?(item[:permission], project)
    end

    # not found allowed import menu
    return false
  end

  def self.import_menu_items(project)
    [
      {
        :item_name => :importer,
        :url => {:controller => 'importer', :action => 'index', :project_id => project},
        :caption => :label_import,
        :permission => :ipf_exec_csv_importer
      },
      {
        :item_name => :ipf_xls_importer,
        :url => {:controller => 'IpfXlsImporter', :action => 'index', :project_id => project},
        :caption => :ipf_imp_xls_label_ipf_xls_importer,
        :permission => :ipf_exec_xls_importer
      },
      {
        :item_name => :msprojects,
        :url => {:controller => 'msprojects', :action => 'index', :project_id => project},
        :caption => :msproject,
        :permission => :msprojects
      },
      {
        :item_name => :ipf_worktime_csv_importer,
        :url => {:controller => 'IpfWorktimeCsvImporter', :action => 'index', :project_id => project},
        :caption => :ipf_wt_imp_csv_label_ipf_csv_importer,
        :permission => :ipf_exec_worktime_csv_importer
      },
      {
        :item_name => :ipf_worktime_xls_importer,
        :url => {:controller => 'IpfWorktimeXlsImporter', :action => 'index', :project_id => project},
        :caption => :ipf_wt_imp_xls_label_ipf_xls_importer,
        :permission => :ipf_exec_worktime_xls_importer
      }
    ]
  end
end
