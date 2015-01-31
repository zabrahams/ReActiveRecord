require_relative 'searchable'
require 'active_support/inflector'

class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )


  def model_class
    class_name.constantize
  end

  def table_name
    model_class.table_name || class_name.tableize
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    defaults = {
      class_name: name.to_s.camelcase,
      foreign_key: :"#{name}_id",
      primary_key: :id
    }

    options = defaults.merge(options)

    @foreign_key = options[:foreign_key]
    @class_name = options[:class_name]
    @primary_key = options[:primary_key]

    self
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    defaults = {
      class_name: name.to_s.camelcase.singularize,
      foreign_key: :"#{self_class_name.underscore}_id",
      primary_key: :id
    }

    options = defaults.merge(options)

    @foreign_key = options[:foreign_key]
    @class_name = options[:class_name]
    @primary_key = options[:primary_key]

    self
  end
end

module Associatable

  def assoc_options
    @assoc_options ||= {}
  end

  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    assoc_options[name] = options

    define_method(name) do
      target_class = options.model_class
      foreign_key_value = self.send(options.foreign_key)

      target_class.where(options.primary_key => foreign_key_value).first
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self.name, options)
    assoc_options[name] = options

    # if options.through
    #   if XXXX && XXXX
    #     return (has_many_belongs_to(name, through_name, source_name))
    #   elsif XXXX && XXXX
    #     return (belongs_to_has_many(name, through_name, source_name))
    #   end
    # end

    define_method(name) do
      target_class = options.model_class
      primary_key_value = self.send(options.primary_key)

      target_class.where(options.foreign_key => primary_key_value)
    end
  end


  def has_one_through(name, through_name, source_name)
    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]

      source_table = source_options.table_name
      through_table = through_options.table_name
      through_id = self.send(through_options.foreign_key)

      through_foreign = "#{through_table}.#{source_options.foreign_key}"
      source_primary = "#{source_table}.#{source_options.primary_key}"
      through_primary = "#{through_table}.#{through_options.primary_key}"

      results = DBConnection.execute(<<-SQL, through_id)
        SELECT
          #{source_table}.*
        FROM
          #{through_table}
        JOIN
          #{source_table} ON #{through_foreign} = #{source_primary}
        WHERE
          #{through_primary} = ?
      SQL
      source_options.model_class.parse_all(results).first
    end
  end

  def has_many_belongs_to(name, through_name, source_name)
    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]

      source_table = source_options.table_name
      through_table = through_options.table_name

      source_foreign = "#{through_table}.#{source_options.foreign_key}"
      source_primary = "#{source_table}.#{source_options.primary_key}"
      through_primary = "#{through_table}.#{through_options.primary_key}"

      results = DBConnection.execute(<<-SQL, self.id)
      SELECT
        #{source_table}.*
      FROM
        #{source_table}
      JOIN
        #{through_table} ON #{source_primary} = #{source_foreign}
      WHERE
        #{through_foreign} = ?
      SQL
      source_options.model_class.parse_all(results)
    end
  end

      # Example has_many => belongs_to query
      # Home has many humans
      # Human belongs to a company
      #
      # SELECT
      #   companies.*
      # FROM
      #   companies
      # JOIN
      #   humans ON humans.company_id = companies.id
      # WHERE
      #   humans.home_id = ? -- homes.id

  def belongs_to_has_many(name, through_name, source_name)
    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]

      source_table = source_options.table_name
      through_table = through_options.table_name
      through_id = self.send(through_options.foreign_key)

      source_foreign = "#{through_table}.#{source_options.foreign_key}"
      source_primary = "#{source_table}.#{source_options.primary_key}"
      through_primary = "#{through_table}.#{through_options.primary_key}"

      results = DBConnection.execute(<<-SQL, through_id)
      SELECT
        #{source_table}.*
      FROM
        #{source_table}
      JOIN
        #{through_table} ON #{source_primary} = #{source_foreign}
      WHERE
        #{through_primary} = ?
      SQL
      source_options.model_class.parse_all(results)
    end
  end

    # Example belongs_to => has_many query
    # Employee belongs to a company
    # Company has many users
    #
    # SELECT
    #   users.*
    # FROM
    #   users
    # JOIN
    #   companies ON companies.id = user.company_id
    # WHERE
    #   companies.id = ? -- employee.company_id
end
