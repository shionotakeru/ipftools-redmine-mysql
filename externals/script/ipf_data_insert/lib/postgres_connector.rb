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
require 'pg'
require 'pp'

class PostgresConnector
  
  # Initialize and connect to DB
  def initialize(host, port, dbname, user, pass)
    @pgconn = PGconn.new(host, port, '', '', dbname, user, pass)
  end

  # Close db connection
  def close
    if connected?
      @pgconn.close
      @pgconn = nil
    end
  end

  # Returns true if db connecting
  def connected?
    (@pgconn != nil)
  end

  # Begin transaction. Block enable
  def transaction
    exec_sql('BEGIN TRANSACTION')

    if block_given?
      begin
        yield
        commit
      rescue
        rollback
        raise
      end
    else
      # block not given
    end
  end

  # Rollback transaction
  def rollback
    exec_sql('ROLLBACK')
  end

  # Commit transaction. if block given, auto commit
  def commit
    exec_sql('COMMIT')
  end

  # Truncate the table
  def truncate(table_name)
    exec_sql("TRUNCATE TABLE #{table_name}")
  end

  # copy to table from csv
  def copy(table_name, csv_file, options = {})
    if options[:truncate]
      truncate(table_name)
    end

    sqlcmd = "COPY #{table_name} FROM '#{csv_file}' CSV"
    exec_sql(sqlcmd)

    unless options[:ignore_id]
      reset_sequence_id(table_name)
    end
  end

  # Re-numbering sequence
  def reset_sequence_id(table_name, column_name = 'id')
    exec_sql("SELECT SETVAL('#{table_name}_#{column_name}_seq', (SELECT MAX(#{column_name}) FROM #{table_name}))")
  end

  # Executing sql
  def exec_sql(sql)
    puts "EXEC SQL -> #{sql}"
    @pgconn.exec(sql)
  end
  
  # Quering sql
  def query_sql(sql)
    puts "QUERY SQL -> #{sql}"
    @pgconn.query(sql)
  end
  
  def get_latest_id(table, column_name = 'id')
    result = exec("SELECT last_value FROM #{table}_#{column_name}_id")
    result.getvalue(0, 0).to_i
  end

  # set 'client_encoding' variable
  def set_client_encoding(encoding)
    exec_sql("set client_encoding='#{encoding}'")
  end

  class << self

    def connect(*args)
      pgobj = new(*args)

      if block_given?
        begin
          yield pgobj
        ensure
          pgobj.close
        end
      else
        pgobj
      end
    end

  end

end