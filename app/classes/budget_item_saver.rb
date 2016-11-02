class BudgetItemSaver
  def save_item_data(budget_item, data)
    self.budget_item = budget_item
    extract_data(data)

    return unless budget_item.present?

    save_code

    def save_possible_duplicates?
      item_is_new && budget_item.respond_to?(:save_possible_duplicates)
    end
  end

  attr_accessor :budget_item,
                :code_number

  private

  def extract_data(data)
    self.code_number = data[:code_number]
  end

  def save_code
    budget_item.add_code(
      code_number: code_number
    )
  end
end
