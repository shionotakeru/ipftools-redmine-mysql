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

require 'rubygems'
require 'active_record'
require 'csv'
require 'digest/sha1'

class ActiveRecord::Base

  def self.from_csv(csv_file)
    data = []

    CSV.open(csv_file, "r") do |row|
      table_row = {}
      idx = 0
      self.columns.each do |column|
        table_row[column.name] = row[idx]

        idx = idx + 1
      end

      data.push(table_row)
    end

    data
  end

  def to_hash
    hashed_data = {}

    self.class.columns.each do |column|
      hashed_data[column.name] = read_attribute(column.name)
    end

    hashed_data
  end
end

class Tracker < ActiveRecord::Base
  has_and_belongs_to_many :projects
  has_and_belongs_to_many :custom_fields, :class_name => 'IssueCustomField', :join_table => "#{table_name_prefix}custom_fields_trackers#{table_name_suffix}", :association_foreign_key => 'custom_field_id'

  def self.all
    find(:all, :order => 'position')
  end
end

class EnabledModule < ActiveRecord::Base
  belongs_to :project

  def self.get_module_names(project_id)
    names = []
    self.find(:all, :select => 'name', :conditions => ['project_id = ?', project_id]).each do |mod|
      names.push mod['name']
    end
    names
  end
end

class CustomField < ActiveRecord::Base
  has_many :custom_values, :dependent => :delete_all

  def self.customized_class
    self.name =~ /^(.+)CustomField$/
    begin; $1.constantize; rescue nil; end
  end

  def type_name
    nil
  end
end

class Issue < ActiveRecord::Base
  belongs_to :project
  belongs_to :tracker
  belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'
  belongs_to :assigned_to, :class_name => 'User', :foreign_key => 'assigned_to_id'
  has_many :time_entries, :dependent => :delete_all
end

class CustomValue < ActiveRecord::Base
  belongs_to :custom_field
  belongs_to :customized, :polymorphic => true
end

class DocumentCategoryCustomField < CustomField
end

class GroupCustomField < CustomField
end

class IssueCustomField < CustomField
  has_and_belongs_to_many :projects, :join_table => "#{table_name_prefix}custom_fields_projects#{table_name_suffix}", :foreign_key => "custom_field_id"
  has_and_belongs_to_many :trackers, :join_table => "#{table_name_prefix}custom_fields_trackers#{table_name_suffix}", :foreign_key => "custom_field_id"
  has_many :issues, :through => :issue_custom_values

  def type_name
    :label_issue_plural
  end
end

class IssuePriorityCustomField < CustomField
end

class ProjectCustomField < CustomField
end

class TimeEntryActivityCustomField < CustomField
end

class TimeEntryCustomField < CustomField
end

class UserCustomField < CustomField
end

class VersionCustomField < CustomField
end

class User < ActiveRecord::Base
  def salt_password(clear_password)
    self.salt = User.generate_salt
    self.hashed_password = User.hash_password("#{salt}#{User.hash_password clear_password}")
  end

  private

  def self.hash_password(clear_password)
    Digest::SHA1.hexdigest(clear_password || "")
  end

  def self.generate_salt
    ActiveSupport::SecureRandom.hex(16)
  end
end

class Member < ActiveRecord::Base
  belongs_to :user
  belongs_to :principal, :foreign_key => 'user_id'
  has_many :member_roles, :dependent => :delete_all
  has_many :roles, :through => :member_roles
  belongs_to :project
end

class MemberRole < ActiveRecord::Base
  belongs_to :member
  belongs_to :role
end

class Project < ActiveRecord::Base
  has_and_belongs_to_many :trackers, :order => "#{Tracker.table_name}.position"
  has_many :enabled_modules, :dependent => :delete_all
  has_and_belongs_to_many :issue_custom_fields,
                          :class_name => 'IssueCustomField',
                          :order => "#{CustomField.table_name}.position",
                          :join_table => "#{table_name_prefix}custom_fields_projects#{table_name_suffix}",
                          :association_foreign_key => 'custom_field_id'
  has_many :time_entries, :dependent => :delete_all

  def enabled_module_names=(module_names)
    if module_names && module_names.is_a?(Array)
      module_names = module_names.collect(&:to_s).reject(&:blank?)
      self.enabled_modules = module_names.collect {|name| enabled_modules.detect {|mod| mod.name == name} || EnabledModule.new(:name => name)}
    else
      enabled_modules.clear
    end
  end

  def self.exists?(id)
    if id.is_a?(String)
      column = 'identifier'
    else
      column = 'id'
    end

    (count(:conditions => ["#{column} = ?", id]) > 0)
  end
end

class TimeEntry < ActiveRecord::Base
  belongs_to :project
  belongs_to :issue
  belongs_to :user
end

class Journal < ActiveRecord::Base
  belongs_to :journalized, :polymorphic => true
  belongs_to :issue, :foreign_key => :journalized_id
  belongs_to :user
  has_many :details, :class_name => "JournalDetail", :dependent => :delete_all
end

class JournalDetail < ActiveRecord::Base
  belongs_to :journal
end

class Wiki < ActiveRecord::Base
end

class WikiPage < ActiveRecord::Base
end

class WikiContent < ActiveRecord::Base
end

class WikiContentVersion < ActiveRecord::Base
end

class Dashboard < ActiveRecord::Base
end

class GraphPattern < ActiveRecord::Base
end


class SourceScale < ActiveRecord::Base
  set_primary_key :project_id
  set_table_name :source_scale
end
