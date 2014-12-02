require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    where_line = params.keys.map { |key| "#{key}= ?"}.join(" AND ")
    values = params.values

    Relation.new(self, table_name, where_line, values)
  end
end

class SQLObject
  extend Searchable
end

class Relation

  def initialize(target_class, table_name, where_line, values)
    @target_class = target_class
    @table_name = table_name
    @where_line = where_line
    @values = values
  end

  def where(params)
    where_line = params.keys.map { |key| "#{key}= ?"}.join(" AND ")
    values = params.values
    @where_line = "(#{@where_line}) AND (#{new_where_line})"
    @values = @values + new_values
    self
  end

  def execute
    results = DBConnection.execute(<<-SQL, *@values)
    SELECT
    *
    FROM
    #{@table_name}
    WHERE
    #{@where_line}
    SQL

    @target_class.parse_all(results)
  end

  def first
    self.execute.first
  end

  def length
    self.execute.length
  end

  def [](index)
    self.execute[index]
  end

  def ==(others)
    self.execute == others
  end

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

class Cat < SQLObject
  self.finalize!
end
