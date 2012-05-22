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

require 'lib/models'
require 'pp'

module NewIpfProject

  def self.collect_for_master_project(master_project_csv_dir)

    # read master project parameters from CSV
    master_project = Project.from_csv(File.join(master_project_csv_dir, "SampleProject_Data_projects.csv")).at(0)
    if master_project.nil?
      return nil
    end

    # read trackers from DB
    tracker = Tracker.all

    # read enabling modules from CSV
    modules = []
    File.open(File.join(master_project_csv_dir, "SampleProject_Data_enabled_modules.csv")) do |f|
      while line = f.gets do
        modules.push line.strip
      end
    end

    master_project['trackers'] = tracker
    master_project['enabled_module_names'] = modules

    # read custom_fields from DB
    custom_fields = CustomField.find(:all)

    # read custom_values from CSV
    custom_values = CustomValue.from_csv(File.join(master_project_csv_dir, "SampleProject_Data_custom_values.csv"))

    master_project_data = {
      'project' => master_project,
      'custom_field' => custom_fields,
      'custom_value' => custom_values
    }

    master_project_data
  end

  def self.collect_for_new_project(new_project_params)

    # read master project parameters from DB
    project = Project.find(:first, :conditions => ['identifier = ?', '__ipfmasterproj__'])
    if project.nil?
      return nil
    end
    project_data = project.to_hash

    # read trackers from DB
    trackers = project.trackers
    # read enabling modules from DB
    modules = EnabledModule.get_module_names(project['id'])

    project_data['trackers'] = trackers
    project_data['enabled_module_names'] = modules

    project_data['name'] = new_project_params[:name]
    project_data['identifier'] = new_project_params[:identifier]
    project_data['created_on'] = project_data['updated_on'] = Time.now.strftime("%Y-%m-%d %H:%M:%S")

    # custom_value is dummy.
    # for sample project, custom value is set by SampleProjectHelper
    new_project_data = {
      'project' => project_data,
      'custom_field' => project.issue_custom_fields,
      'custom_value' => []
    }

    new_project_data
  end

  def self.create_new_project(project_data)
    project = project_data['project']

    # assign issue custom field to project
    self.assign_issue_custom_fields_to_project(project, project_data['custom_field'])

    # create new project
    new_project = self.create_project(project)
    new_id = new_project[:id]

    # assign project custom field
    self.assign_custom_fields_to_project(new_id, project_data['custom_field'])

    # set custom values
    self.set_custom_values(new_id, project_data['custom_value'])

    new_id
  end

  private

  def self.assign_issue_custom_fields_to_project(project, custom_fields)
    project['issue_custom_field_ids'] = []

    custom_fields.each do |field|
      next unless field.is_a?(IssueCustomField)

      project['issue_custom_field_ids'].push field.id
    end
  end

  def self.create_project(project)
    new_project = Project.create(project)
    new_id = new_project[:id]
    new_project[:lft] = new_id * 2 - 1
    new_project[:rgt] = new_id * 2
    new_project.save!

    new_project
  end

  def self.assign_custom_fields_to_project(project_id, custom_fields)
    custom_fields.each do |field|
      next unless field.is_a?(ProjectCustomField)

    end
  end

  def self.set_custom_values(project_id, custom_values)
    custom_values.each do |value|
      if value['customized_type'] == 'Project'
        value['customized_id'] = project_id
      end

      CustomValue.create(value)
    end
  end
end
