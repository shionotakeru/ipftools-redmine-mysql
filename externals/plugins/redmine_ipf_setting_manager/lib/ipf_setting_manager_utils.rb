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

#= IPF setting manager plugin utilities
#
module IpfSettingManagerUtils

  #===Send the HTTP response body format JSON.
  #
  def send_response_json(result_code, message = nil)
    respond_to do |format|
      format.json do
        render :json => {:result => result_code, :message => message }
      end
    end
  end
    
  #===get error message 
  #  
  def get_error_message(result_code)
    if 1 == result_code then
      # Standard error
      message = l('ipf_sm_error_msg_unexpected')
    else
      # script error
      message_key = 'ipf_sm_error_msg_' + result_code.to_s
      if l(message_key, :default => 'nokey') != 'nokey'
        l(message_key)
      else
        l('ipf_sm_error_msg_unexpected')
      end
    end
  end
  
end

