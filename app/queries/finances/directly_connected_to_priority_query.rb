class Finances::DirectlyConnectedToPriorityQuery
  attr_reader :priority,
              :finance_model

  def initialize(priority, finance_model)
    @priority = priority
    @finance_model = finance_model
  end

  def call
    finance_model.where(id: all_directly_connected_finances).prefer_official
  end

  private

  def all_directly_connected_finances
    arel = finance_table
    .project(finance_table[:id])
    .join(priority_connections_table)
    .on(finance_table[finance_model.budget_item_id_field].eq(priority_connections_table[:priority_connectable_id]).and(finance_table[finance_model.budget_item_type_field].eq(priority_connections_table[:priority_connectable_type])))
    .where(priority_connections_table[:direct].eq(true))
    .where(priority_connections_table[:start_date].lteq(finance_table[:start_date]))
    .where(priority_connections_table[:end_date].gteq(finance_table[:end_date]))
    .where(priority_connections_table[:priority_id].eq(priority.id))

    finance_model.find_by_sql(arel.to_sql)
  end

  def finance_table
    finance_model.arel_table
  end

  def priority_connections_table
    PriorityConnection.arel_table
  end
end
