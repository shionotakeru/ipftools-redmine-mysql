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

require 'active_record'
require 'lib/models'
require 'pp'

class SampleProjectHelper
  attr_accessor :project_id

  def initialize
    @mapping_data = {}
  end

  def connect(database_config)
    if block_given?
      begin
        disconnect

        ActiveRecord::Base.establish_connection(database_config)

        yield
      ensure
        disconnect
      end
    else
      raise RuntimeError.new('block must need.')
    end
  end

  def disconnect
    if ActiveRecord::Base.connected?
      ActiveRecord::Base.connection.disconnect!
    end
  end

  def create_sample_project(project_data, sample_data_path)
    new_project_id = NewIpfProject.create_new_project(project_data)
    self.project_id = new_project_id

    @project = Project.find(self.project_id)

    user_data_csv = User.from_csv(File.join(sample_data_path, 'SampleProject_Data_users.csv'))
    member_csv = Member.from_csv(File.join(sample_data_path, 'SampleProject_Data_members.csv'))
    member_roles_csv = MemberRole.from_csv(File.join(sample_data_path, 'SampleProject_Data_member_roles.csv'))

    # for admin user
    add_id_map(:user, 1, 1)

    # create users table
    user_data_csv.each do |user_data|
      user_db = User.create(user_data) do |user|
        user.salt_password(user_data['hashed_password'])
        user[:type] = 'User'
      end

      add_id_map(:user, user_data['id'], user_db.id)

      #member_orig_index = member_csv.index { |data| data['user_id'] == user_data['id'] }

      #member_data = {:user_id => user_db.id, :project_id => self.project_id}
      #member_db = Member.create(member_data)

      #add_id_map(:member, member_csv[member_orig_index]['id'], member_db.id)
    end

    # create members table
    member_csv.each do |member_data|
      member_db = Member.create(member_data) do |data|
        data.user_id = get_mapped_id(:user, data.user_id)
        data.project_id = self.project_id
      end

      add_id_map(:member, member_data['id'], member_db.id)
    end

    # create member_roles table
    member_roles_csv.each do |member_roles_data|
      member_roles_data['member_id'] = get_mapped_id(:member, member_roles_data['id'])

      MemberRole.create(member_roles_data)
    end

    # create issues table
    issues_csv = Issue.from_csv(File.join(sample_data_path, 'SampleProject_Data_issues.csv'))
    issues_csv.each do |issue_data|
      data = issue_verify(issue_data)

      issue_db = Issue.create(data) do |issue|
        issue.project_id = self.project_id
      end
      add_id_map(:issue, issue_data['id'], issue_db.id)
    end

    # modify root_id and parent_id for issues table
    issues_db = Issue.find(:all, :conditions => ['project_id = ?', self.project_id])
    unless issues_db.nil?
      issues_db.each do |issue|
        issue.root_id = get_mapped_id(:issue, issue.root_id) unless issue.root_id.nil?
        issue.parent_id = get_mapped_id(:issue, issue.parent_id) unless issue.parent_id.nil?
        issue.save!
      end
    end

    # create custom_values table
    custom_values_csv = CustomValue.from_csv(File.join(sample_data_path, 'SampleProject_Data_custom_values.csv'))
    custom_values_csv.each do |custom_value_data|
      data = custom_value_verify(custom_value_data)

      CustomValue.create(data)
    end

    # create time_entries table
    time_entries_csv = TimeEntry.from_csv(File.join(sample_data_path, 'SampleProject_Data_time_entries.csv'))
    time_entries_csv.each do |time_entry_data|
      time_entry_data['project_id'] = self.project_id
      time_entry_data['issue_id'] = get_mapped_id(:issue, time_entry_data['issue_id'])
      time_entry_data['user_id'] = get_mapped_id(:user, time_entry_data['user_id'])

      TimeEntry.create(time_entry_data)
    end

    # create journals table
    journals_csv = Journal.from_csv(File.join(sample_data_path, 'SampleProject_Data_journals.csv'))
    journals_csv.each do |journal_data|
      case journal_data['journalized_type']
      when 'Issue'
        journal_data['journalized_id'] = get_mapped_id(:issue, journal_data['journalized_id'])
      end
      journal_data['user_id'] = get_mapped_id(:user, journal_data['user_id'])

      journal_db = Journal.create(journal_data)
      add_id_map(:journal, journal_data['id'], journal_db.id)
    end

    # create journal_details table
    journal_details_csv = JournalDetail.from_csv(File.join(sample_data_path, 'SampleProject_Data_journal_details.csv'))
    journal_details_csv.each do |journal_detail_data|
      verify_data = journal_detail_verify(journal_detail_data)
      JournalDetail.create(verify_data)
    end

    # create wiki tables
    create_wiki_tables(sample_data_path)

    # create graph pattern table
    graph_patterns_csv = GraphPattern.from_csv(File.join(sample_data_path, 'SampleProject_Data_graph_patterns.csv'))
    graph_patterns_csv.each do |graph_pattern_data|
      graph_pattern_db = GraphPattern.create(graph_pattern_data) do |data|
        data.project_id = self.project_id
      end

      add_id_map(:graph_pattern, graph_pattern_data['id'], graph_pattern_db.id)
    end

    # create dashboard table
    dashboard_csv = Dashboard.from_csv(File.join(sample_data_path, 'SampleProject_Data_dashboards.csv'))
    dashboard_csv.each do |dashboard_data|
      Dashboard.create(dashboard_data) do |data|
        data.user_id = get_mapped_id(:user, data['user_id'])
        data.project_id = self.project_id
        data.graph_pattern_id = get_mapped_id(:graph_pattern, data['graph_pattern_id'])
      end
    end
  end

  def insert_source_data(sample_data_path)
    source_scale_csv = SourceScale.from_csv(File.join(sample_data_path, 'SampleProject_Data_source_scale.csv'))

    source_scale_csv.each do |source_scale_data|
      source_scale_data['ticket_id'] = get_mapped_id(:issue, source_scale_data['ticket_id'])
      source_scale_data['change_user_id'] = get_mapped_id(:user, source_scale_data['change_user_id'])

      source_scale_db = SourceScale.new(source_scale_data)
      source_scale_db.project_id = @project[:identifier]
      source_scale_db.save
    end
  end

  def execute_pf_batch(batch_path)
    batch_command = File.join(batch_path, "B001ROE", "B001ROE_1")
    batch_command += ((win32?) ? ".bat": ".sh")
    batch_command = "#{batch_command} #{@project[:identifier]}"

    system batch_command
    $?.exitstatus
  end

  def execute_graph_batch(batch_path)
    graph_batch_dir = File.join(batch_path, "B004IOE")
    Dir.open(graph_batch_dir).each do |file|
      if /^B004IOE.*$/ =~ file
        batch_file = File.join(graph_batch_dir, file)
        if batch_executable?(batch_file)
          proc_number = file.gsub(/^B004IOE_(\d+).*$/, '\\1')
          batch_command = "#{batch_file} #{@project[:identifier]} #{proc_number}"

          system batch_command
          if $? != 0
            return $?.exitstatus
          end
        end
      end
    end

    return 0
  end

  private

  def add_id_map(key, oldid, newid)
    if @mapping_data.key?(key)
      @mapping_data[key].merge!(oldid.to_s => newid)
    else
      @mapping_data.merge!(key => {oldid.to_s => newid})
    end
  end

  def get_mapped_id(key, oldid)
    begin
      @mapping_data[key][oldid.to_s]
    rescue
      nil
    end
  end

  def issue_verify(issue_data)
    unless issue_data['author_id'].nil?
      issue_data['author_id'] = get_mapped_id(:user, issue_data['author_id'])
    end
    unless issue_data['assigned_to_id'].nil?
      issue_data['assigned_to_id'] = get_mapped_id(:user, issue_data['assigned_to_id'])
    end

    issue_data
  end

  def custom_value_verify(custom_value_data)
    case custom_value_data['customized_type']
    when 'Project'
      custom_value_data['customized_id'] = self.project_id
    when 'Issue'
      custom_value_data['customized_id'] = get_mapped_id(:issue, custom_value_data['customized_id'])
    end

    field = CustomField.find(custom_value_data['custom_field_id'])
    if field.field_format == 'user'
      custom_value_data['value'] = get_mapped_id(:user, custom_value_data['value']).to_s
    end

    custom_value_data
  end

  def journal_detail_verify(journal_detail_data)
    case journal_detail_data['property']
    when 'attr'
      case journal_detail_data['prop_key']
      when 'assigned_to_id', 'author_id'
        journal_detail_data['old_value'] = get_mapped_id(:user, journal_detail_data['old_value'])
        journal_detail_data['value'] = get_mapped_id(:user, journal_detail_data['value'])
      end
    when 'cf'
      custom_field = CustomField.find(journal_detail_data['prop_key'])
      unless custom_field.nil?
        if custom_field.field_format == 'user'
          journal_detail_data['old_value'] = get_mapped_id(:user, journal_detail_data['old_value'])
          journal_detail_data['value'] = get_mapped_id(:user, journal_detail_data['value'])
        end
      end
    end
    journal_detail_data['journal_id'] = get_mapped_id(:journal, journal_detail_data['journal_id'])

    journal_detail_data
  end

  def create_wiki_tables(sample_data_path)
    # create wikis table
    wikis_csv = Wiki.from_csv(File.join(sample_data_path, 'SampleProject_Data_wikis.csv'))
    wikis_csv.each do |wiki_data|
      wiki_data['project_id'] = self.project_id

      wiki_db = Wiki.create(wiki_data)
      add_id_map(:wiki, wiki_data['id'], wiki_db.id)
    end

    # create wiki_page table
    wiki_pages_csv = WikiPage.from_csv(File.join(sample_data_path, 'SampleProject_Data_wiki_pages.csv'))
    wiki_pages_csv.each do |wiki_page_data|
      wiki_page_data['wiki_id'] = get_mapped_id(:wiki, wiki_page_data['wiki_id'])

      wiki_page_db = WikiPage.create(wiki_page_data)
      add_id_map(:wiki_page, wiki_page_data['id'], wiki_page_db.id)
    end

    # verifying wiki_pages.parent_id
    wiki_pages_csv.each do |wiki_page_data|
      page_id = get_mapped_id(:wiki_page, wiki_page_data['id'])

      unless wiki_page_data['parent_id'].nil?
        wiki_page_db = WikiPage.find(page_id)
        wiki_page_db.parent_id = get_mapped_id(:wiki_page, wiki_page_data['parent_id'])
        wiki_page_db.save!
      end
    end

    # create wiki_content and wiki_content_version table
    wiki_contents_csv = WikiContent.from_csv(File.join(sample_data_path, 'SampleProject_Data_wiki_contents.csv'))
    wiki_contents_csv.each do |wiki_content_data|
      wiki_content_data['page_id'] = get_mapped_id(:wiki_page, wiki_content_data['page_id'])
      wiki_content_data['author_id'] = get_mapped_id(:user, wiki_content_data['author_id'])

      wiki_content_db = WikiContent.create(wiki_content_data)

      wiki_content_version_data = {
        'wiki_content_id' => wiki_content_db.id,
        'page_id' => wiki_content_db.page_id,
        'author_id' => wiki_content_db.author_id,
        'data' => wiki_content_db.text,
        'comments' => wiki_content_db.comments,
        'updated_on' => wiki_content_db.updated_on,
        'version' => wiki_content_db.version
      }
      WikiContentVersion.create(wiki_content_version_data)
    end
  end

  def win32?
    (RUBY_PLATFORM.downcase =~ /mswin(?!ce)|mingw|cygwin|bccwin/)
  end

  def batch_executable?(file_path)
    return false unless File.extname(file_path) == ((win32?) ? ".bat": ".sh")
    File.stat(file_path).executable?
  end

end
