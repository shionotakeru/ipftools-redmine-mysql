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

require 'redmine'
#require_dependency 'issues_controller' 
module IpfWtExpXLSPatch

  #
  #=== The addition of the method to method chain 
  #
  #_base_ :: base 
  #
  def self.included(base) # :nodoc:    
    base.send(:include, IpfXLSInstanceMethods)     
    base.class_eval do      
      unloadable
      # have to include all the bunch from original controller because of Rails implementation
      # of before_filter :authorize
      filter_chain = @inheritable_attributes["filter_chain"]
      filter_chain.each do |entry| 
        if entry.method.to_s == "authorize"
          except = entry.options[:except]
          except << "ipf_wt_exp_xls_action"
        end
      end
      
		  before_filter :find_optional_project_worktime_xls, :only => [:ipf_wt_exp_xls_action]
		  
      alias_method_chain :index, :ipf_wt_exp_xls
    end
  end

	module IpfXLSInstanceMethods

		include IssuesHelper
    include Redmine::Ipf::Worktime::Export::XLS
		
    #
    #=== xml export processing main part 
    #
	  def index_with_ipf_wt_exp_xls
			if params[:format] != 'xlsx'
				return index_without_ipf_wt_exp_xls
			end
			
			if retrieve_ipf_wt_exp_xls_data
				export_name = get_ipf_wt_exp_xls_name
				send_data(worktime_to_xls2(@issues, @project, @query, @settings), :type => :xls, :filename => export_name)
			else
	      # Send html if the query is not valid
	      render(:template => 'issues/index.rhtml', :layout => !request.xhr?)
			end
	  end
	  
    #
    #=== Option screen action 
    #
		def ipf_wt_exp_xls_action
			if request.post?
				@settings = params[:settings]
				if retrieve_ipf_wt_exp_xls_data(@settings)
					export_name = get_ipf_wt_exp_xls_name
					send_data(worktime_to_xls2(@issues, @project, @query, @settings), :type => :xls, :filename => export_name)
				else
					redirect_to :action => 'index', :project_id => @project				
				end
			end
			@settings=Setting["plugin_ipf_wt_exp_xls"]
		end

private

    #
    #=== Data extraction processing 
    #
    #_settings_ :: Option configuration information 
    #
		def retrieve_ipf_wt_exp_xls_data(settings=nil)
			params[:query_id]=session[:query][:id] if !session[:query].nil? && !session[:query][:id].blank?
			if !params[:query_id].blank? && !session['issues_index_sort'].blank?
				user_sort_string=session['issues_index_sort']
				retrieve_query
				session['issues_index_sort']=user_sort_string if session['issues_index_sort'].blank?
			else
				retrieve_query
			end
			params[:sort]=session['issues_index_sort'] if params[:sort].nil? && !session['issues_index_sort'].nil?
	    sort_init(@query.sort_criteria.empty? ? [['id', 'desc']] : @query.sort_criteria)
	    sort_update(@query.sortable_columns)
	    
	    if @query.valid?
	    	limit = ( settings && settings[:issues_limit].to_i>0 ? settings[:issues_limit].to_i : Setting.issues_export_limit.to_i )
	      @issue_count = @query.issue_count
	      @issue_pages = ActionController::Pagination::Paginator.new self, @issue_count, limit, params['page']
	      @issues = @query.issues(:include => [:assigned_to, :tracker, :priority, :category, :fixed_version],
	                              :order => sort_clause, 
	                              :offset => @issue_pages.current.offset, 
	                              :limit => limit)
	      @issue_count_by_group = @query.issue_count_by_group
	      @settings=Setting["plugin_ipf_wt_exp_xls"] unless settings

	      return true
	    end
	    	
	    return false
	  rescue ActiveRecord::RecordNotFound
	    render_404
		end
		
    #
    #=== Project search and a user authority judging 
    #
		def find_optional_project_worktime_xls
			@project = Project.find(params[:project_id]) unless params[:project_id].blank?
			allowed = User.current.allowed_to?({:controller => params[:controller], :action => :index}, @project, :global => true)
			allowed ? true : deny_access
		rescue ActiveRecord::RecordNotFound
			render_404
		end
		
    #
    #=== Transmitting file name acquisition 
    #
		def get_ipf_wt_exp_xls_name
			return "export.xls" unless !@settings['export_name'].blank?
			return "#{@settings['export_name']}.xls" unless @settings['generate_name'] == '1'
			
			fnm = ''
			fnm << (@project ? @project.to_s : l(:label_project_plural)).gsub(' ','_') << '_' << @settings['export_name'] << '.xls'
			
			return fnm
		end

	end

end
