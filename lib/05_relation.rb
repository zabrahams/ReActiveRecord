class Relation

  def initialize(target_class, table_name)
    @target_class = target_class
    @table_name = table_name
    @values = []
  end

  def where(params)
    new_where_line = params.keys.map { |key| "#{key}= ?"}.join(" AND ")
    new_values = params.values

    if @where_line
      @where_line = "(#{@where_line}) AND (#{new_where_line})"
    else
      @where_line = new_where_line
    end
    @values = @values + new_values

    self
  end

  def include(assoc_name)
    assoc_options = @target_class.assoc_options[assoc_name]

    target_results = self.execute
    ids = target_results.map(&:id)

    assoc_results = DBConnection.execute(<<-SQL, *ids)
      SELECT
        *
      FROM
        #{assoc_name.to_s.tableize}
      WHERE
        #{assoc_name.to_s.tableize}.#{assoc_options.foreign_key} IN (#{ (["?"] * ids.length).join(", ") })
    SQL

    assoc_results = assoc_options.model_class.parse_all(assoc_results)

    @target_class.send(:define_method, assoc_name) do
      assoc_results.select do |result|
        result.send(assoc_options.foreign_key) == self.id
      end
    end

    target_results
  end


  def execute

    p @where_line
    p @values

    if @where_line.empty?
      where_clause = ""
    else
      where_clause = <<-SQL
      WHERE
        #{@where_line}
      SQL
    end

    results = DBConnection.execute(<<-SQL, *@values)
    SELECT
      *
    FROM
      #{@table_name}
    #{where_clause}
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
