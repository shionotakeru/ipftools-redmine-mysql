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
require 'webrick'

module WEBrick
  module HTTPAuth
    class Htdigest
      def change_username(realm, oldname, newname)
        if hash = @digest[realm]
          pass = hash[oldname]
          hash.delete(oldname)
          @digest[realm][newname] = pass
        end
      end
    end
  end
end


module IpfUserHtdigestPatch
  def self.included(base)
    base.class_eval do
      alias_method_chain :before_save, :before_save_for_htdigest
      alias_method_chain :after_save, :after_save_for_htdigest
      alias_method_chain :after_destroy, :after_destroy_for_htdigest
    end
  end

  def before_save_with_before_save_for_htdigest
    before_save_without_before_save_for_htdigest

    begin
      @old_user = User.find(self.id)
    rescue => err
      @old_user = nil
    end
  end

  def after_save_with_after_save_for_htdigest
    after_save_without_after_save_for_htdigest

    digest_file = Setting.plugin_redmine_ipf_setting_manager['ipf_htdigest_file']

    return if digest_file.nil?
    return unless File.exist?(digest_file)

    digest = WEBrick::HTTPAuth::Htdigest.new(digest_file)
    if @old_user.nil?
      # create user
      unless self.anonymous? || self.login.nil?
        digest.set_passwd('ipftools', self.login, self.password)
        digest.flush
      end
    else
      # modify user
      updated = false
      if (@old_user.login <=> self.login) != 0
        if digest.get_passwd('ipftools', @old_user.login, false)
          digest.change_username('ipftools', @old_user.login, self.login)
          updated = true
        end
      end
      if self.password
        digest.set_passwd('ipftools', self.login, self.password)
        updated = true
      end

      if updated
        digest.flush
      end
    end
  end

  def after_destroy_with_after_destroy_for_htdigest
    after_destroy_without_after_destroy_for_htdigest

    digest = WEBrick::HTTPAuth::Htdigest.new(Setting.plugin_redmine_ipf_setting_manager['ipf_htdigest_file'])
    if digest.get_passwd('ipftools', self.login, false)
      digest.delete_passwd('ipftools', self.login)
      digest.flush
    end
  end
end
