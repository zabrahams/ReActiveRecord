require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    where_line = params.keys.map { |key| "#{key}= ?"}.join(" AND ")
    values = params.values
    table = table_name

    results = DBConnection.execute(<<-SQL, *values)
      SELECT
        *
      FROM
        #{table}
      WHERE
        #{where_line}
    SQL

    results.map { |result| self.new(result) }
  end
end

class SQLObject
  extend Searchable
end
