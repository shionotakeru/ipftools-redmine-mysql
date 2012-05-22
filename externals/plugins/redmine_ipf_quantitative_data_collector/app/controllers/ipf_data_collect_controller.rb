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

require 'pp'
require 'yaml'

#
#=IPF Quantitative Data Collector, Controller class
#
class IpfDataCollectController < ApplicationController
  unloadable

  menu_item :ipf_quantitative_data_collector
  before_filter :read_config_file, :find_project
  before_filter :authorize, :only => [:index]

  #
  #=== Show IPF-QDC index page
  #
  def index
    project_id = @project[:id].to_s

    pfdatalist = IpfQuantitativeDataMaster.get_pf_data_table
    @pfItems = []
    pfdatalist.each do |item|
      @pfItems.push({
        :proc_id => item[:proc_id],
        :name => item[:name],
        :collect_to => item[:column2],
        :update_date => get_update_date(project_id, item[:batch_id], item[:proc_id])
      })
    end

    graphdatalist = IpfQuantitativeDataMaster.get_graph_data_table
    @graphItems = []
    graphdatalist.each do |item|
      names = item[:name].split(/,/) rescue []
      tables = item[:column1].split(/,/) rescue []
      graphs = item[:column2].split(/,/) rescue []

      @graphItems.push({
        :proc_id => item[:proc_id],
        :names => names,
        :tables => tables,
        :graphs => graphs,
        :update_date => get_update_date(project_id, item[:batch_id], item[:proc_id])
      })
    end

    @check_interval = @config_data[ :check_interval ]
  end

  #=== Execute collecting batch program
  #
  #==== JSON
  #
  # JSON structures.
  #
  #_result_ :: return code
  #_update_date_ :: update date (ok only)
  #_message_ :: error message
  def execute
    project_id = @project[:identifier]
    proc_id = params[:proc_id]

    if params[:mode] == 'graph' then
      batch_list = IpfQuantitativeDataMaster.get_pf_batch_id
    else
      batch_list = IpfQuantitativeDataMaster.get_graph_batch_id
    end
    batch_list.each do |batch|
      if check_executing?(project_id, batch[:batch_id], batch[:proc_id]) then
        send_response_json 10, t('ipf_quantitative_data_collector.' + params[:mode] + '.other_executing_msg')
        return
      end
    end

    collect_type = (params[:mode] == 'graph') ? 1: 0

    batch_id = IpfQuantitativeDataMaster.get_batch_id(collect_type, params[:proc_id]) rescue nil
    if batch_id == '' then
      send_response_json 11, "internal server error"
      return
    end

    if check_executing?(project_id, batch_id, proc_id) then
      send_response_json 9, t('ipf_quantitative_data_collector.proc_executing_msg')
      return
    end

    batch_command = File.join(@config_data[:batch_path], "#{batch_id}", "#{batch_id}_#{proc_id}")
    batch_command += ((win32?) ? ".bat": ".sh")
    batch_command += " #{project_id}"
    if params[:mode] == 'graph' then
      batch_command += " #{proc_id}"
    end
    system batch_command

    if $? == 0 then
      update_date = get_update_date(project_id, batch_id, proc_id)
      result_code = 0
      message = ''
    else
      errfile = File.join(@config_data[:batch_log], project_id, "batch", "result", "#{batch_id}_#{proc_id}.err")
      begin
        File.open(errfile, "r") do |f|
          message = f.read
        end
        message.strip!
      rescue
        message = 'Internal server error'
      end
      result_code = $?.exitstatus
    end

    send_response_json result_code, message, update_date
  end

  #
  #=== Check batch programs executing
  #
  #==== JSON
  #
  # JSON structure
  #
  #_pf_ :: Array of Project manage PF data
  #_graph_ :: Array of Graph view Data
  #
  #_id_ :: number of batch
  #_batch_id_ :: batch process id
  #_processing_ :: true is executing, false is idling
  #_update_date_ :: update date
  def check
    project_id = params[:project_id]

    pfdatalist = IpfQuantitativeDataMaster.get_pf_data_table
    pfcheckedlist = []
    pfdatalist.each do |data|
      pfcheckedlist.push({
        :id => data[:proc_id],
        :processing => check_executing?(project_id, data[:batch_id], data[:proc_id]),
        :update_date => get_update_date(project_id, data[:batch_id], data[:proc_id])
      })
    end

    graphdatalist = IpfQuantitativeDataMaster.get_graph_data_table
    graphcheckedlist = []
    graphdatalist.each do |data|
      graphcheckedlist.push({
        :id => data[:proc_id],
        :processing => check_executing?(project_id, data[:batch_id], data[:proc_id]),
        :update_date => get_update_date(project_id, data[:batch_id], data[:proc_id])
      })
    end

    respond_to do |format|
      format.json do
        render :json => {"pf" => pfcheckedlist, "graph" => graphcheckedlist}
      end
    end
  end

  private

  def find_project
    @project = Project.find(params[:project_id])
  end

  #
  #===Check batch program executing
  #
  def check_executing?(project_id, batch_id, proc_id)
    lock_file = File.join(@config_data[:batch_log], project_id, "batch", "result", "#{batch_id}_#{proc_id}.lock")
    return false unless File.exist?(lock_file)

    lock_time = File::Stat.new(lock_file).mtime
    lock_spent_time = Time.at(params[:tt].to_i) - lock_time

    (lock_spent_time < (@config_data[:lock_lifetime] * 60))
  end

  #
  #===Get update date from batch result file.
  #
  def get_update_date(project_id, batch_id, proc_id)
    success_file = File.join(@config_data[:batch_log], project_id, "batch", "result", "#{batch_id}_#{proc_id}.ok")

    update_date = ''
    if File.exist?(success_file) then
      File.open success_file, "r" do |f|
        update_date = f.read
      end
    end

    return update_date.strip
  end

  #
  #===Read IPF-QDC configuration
  #
  def read_config_file
    @config_data = {
      :check_interval => (Integer(Setting.plugin_redmine_ipf_quantitative_data_collector['ipf_qdc_check_interval']) rescue 60000),
      :batch_path => Setting.plugin_redmine_ipf_quantitative_data_collector['ipf_qdc_batch_path'],
      :batch_log => Setting.plugin_redmine_ipf_quantitative_data_collector['ipf_qdc_batch_log_path'],
      :lock_lifetime => (Integer(Setting.plugin_redmine_ipf_quantitative_data_collector['ipf_qdc_lock_lifetime']) rescue 30),
    }
  end

  #
  #===send HTTP response by JSON format
  #
  def send_response_json(result_code, message, update_date = '')
    respond_to do |format|
      format.json do
        render :json => {"result" => result_code, "message" => message, "update_date" => update_date}
      end
    end
  end

  def win32?
    (RUBY_PLATFORM.downcase =~ /mswin(?!ce)|mingw|cygwin|bccwin/)
  end
end
