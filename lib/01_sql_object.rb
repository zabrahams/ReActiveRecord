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
        attributes[column]
      end

      define_method("#{column}=") do |value|
        attributes[column] = value
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
    table = self.table_name
    results = DBConnection.execute(<<-SQL)
      SELECT
        #{table}.*
      FROM
        #{table}
    SQL
    self.parse_all(results)
  end

  def self.parse_all(results)
    results.map { |result| self.new(result) }
  end

  def self.find(id)
    table = self.table_name
    result = DBConnection.instance.get_first_row(<<-SQL, id)
      SELECT
        #{table}.*
      FROM
        #{table}
      WHERE
        #{table}.id = ?
    SQL

    result || (return nil)
    self.new(result)
  end

  def initialize(params = {})
    cols = self.class.columns
    params.each do |attr_name, value|
      attr_sym = attr_name.to_sym
      unless cols.include?(attr_sym)
        fail "unknown attribute '#{attr_name}'"
      end
      self.send(:"#{attr_name}=", value)
    end

    self
  end

  def attributes
    @attributes || @attributes = {}
  end

  def attribute_values
    cols = self.class.columns
    cols.map { |column| self.send(column) }
  end

  def insert
    table = self.class.table_name
    cols = self.class.columns
    cols.delete(:id)
    non_id_attributes = attribute_values[1..-1]

    DBConnection.execute(<<-SQL, *non_id_attributes)
      INSERT INTO
        #{table} (#{cols.join(", ")})
      VALUES
        (#{(["?"] * cols.count).join(", ")})
    SQL

    new_id = DBConnection.last_insert_row_id
    self.attributes[:id] = new_id

    self
  end

  def update
    table = self.class.table_name
    cols = self.class.columns
    attr_values = attribute_values
    attr_values << attr_values[0]

    DBConnection.execute(<<-SQL, *attr_values)
      UPDATE
        #{table}
      SET
        #{ cols.map { |column| "#{column} = ?" }.join(", ") }
      WHERE
        id = ?
    SQL

    self
  end

  def save
    # ...
  end
end
