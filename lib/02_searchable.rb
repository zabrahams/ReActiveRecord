require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    where_line = params.keys.map { |key| "#{key}= ?"}.join(" AND ")
    values = params.values

    if self.class == Relation
      self.stack(where_line, values)
    else
      Relation.new(self, table_name, where_line, values)
    end

  end
end

class SQLObject
  extend Searchable
end

class Relation
  include Searchable

  def initialize(target_class, table_name, where_line, values)
    @target_class = target_class
    @table_name = table_name
    @where_line = where_line
    @values = values
  end

  def stack(new_where_line, new_values)
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

end

module OldSearchable
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

    self.parse_all(results)
  end
end

## Testing code below!

class Cat < SQLObject
  self.finalize!
end
