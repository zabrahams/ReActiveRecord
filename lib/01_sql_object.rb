require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    table = self.table_name
    cols = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{table}
    SQL
    cols = cols.first.map(&:to_sym)
  end

  def self.finalize!
    cols = self.columns
    cols.each do |column|

      define_method("#{column}") do
        @attributes[column]
      end

      define_method("#{column}=") do |value|
        @attributes[column] = value
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name = self.name.tableize unless @table_name
    @table_name
  end

  def self.all
    # ...
  end

  def self.parse_all(results)
    # ...
  end

  def self.find(id)
    # ...
  end

  def initialize(params = {})
    # ...
  end

  def attributes
    @attributes = {}
  end

  def attribute_values
    # ...
  end

  def insert
    # ...
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
