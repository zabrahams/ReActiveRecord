require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key,
    :table_name
  )


  def model_class
    class_name.constantize
  end

  def table_name
    Module.const_get(class_name).table_name || class_name.tableize
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    defaults = {
      class_name: name.camelcase,
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
      class_name: name.camelcase.singularize,
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
  # Phase IIIb
  def belongs_to(name, options = {})
    # ...
  end

  def has_many(name, options = {})
    # ...
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  extend Associatable
end
