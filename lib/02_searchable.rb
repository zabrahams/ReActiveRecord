require_relative 'db_connection'
require_relative '01_sql_object'
require_relative '05_relation'

module Searchable
  def where(params)
    Relation.new(self, table_name).where(params)
  end
end

class SQLObject
  extend Searchable
end



# module OldSearchable
#   def where(params)
#     where_line = params.keys.map { |key| "#{key}= ?"}.join(" AND ")
#     values = params.values
#     table = table_name
#
#     results = DBConnection.execute(<<-SQL, *values)
#     SELECT
#     *
#     FROM
#     #{table}
#     WHERE
#     #{where_line}
#     SQL
#
#     self.parse_all(results)
#   end
# end

## Testing code below!
