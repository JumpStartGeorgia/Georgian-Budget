class BudgetDataSaver
  def initialize(data_holder)
    @data_holder = data_holder
    @budget_item_fetcher = BudgetItemFetcher.new
  end

  def save_data
    return unless budget_item.present?

    save_code
    save_name
    save_spent_finance
    save_planned_finance

    if budget_item_fetcher.created_new_item && budget_item.respond_to?(:save_possible_duplicates)
      budget_item.save_possible_duplicates
    end
  end

  private

  def budget_item
    @budget_item ||= budget_item_fetcher.fetch(
      create_if_nil: true,
      code_number: data_holder.code_number,
      name_text: data_holder.name_text
    )
  end

  def save_code
    return unless budget_item.respond_to?(:add_code)
    budget_item.add_code(data_holder.code_data)
  end

  def save_name
    return unless budget_item.respond_to?(:add_name)
    budget_item.add_name(data_holder.name_data)
  end

  def save_spent_finance
    budget_item.add_spent_finance(
      data_holder.spent_finance_data(budget_item: budget_item)
    )
  end

  def save_planned_finance
    budget_item.add_planned_finance(
      data_holder.planned_finance_data(budget_item: budget_item)
    )
  end

  attr_reader :data_holder,
              :budget_item_fetcher
end
