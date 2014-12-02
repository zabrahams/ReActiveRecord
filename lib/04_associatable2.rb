require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

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
end
