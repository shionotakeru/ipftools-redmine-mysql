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

class CreateIpfQuantitativeDataMasters < ActiveRecord::Migration
  def self.up
    create_table :ipf_quantitative_data_masters do |t|
      t.column :proc_id, :integer
      t.column :name, :string
      t.column :collect_type, :integer
      t.column :batch_id, :string
      t.column :column1, :string
      t.column :column2, :string
    end

    initfile = File.dirname(__FILE__) + '/ipf_quantitative_data_master_initdata.yml'
    initdata = []
    File.open(initfile, "r") do |f|
      initdata = YAML.load(f.read)
    end
    initdata.each do |data|
      IpfQuantitativeDataMaster.create(data)
    end
  end

  def self.down
    drop_table :ipf_quantitative_data_masters
  end
end
