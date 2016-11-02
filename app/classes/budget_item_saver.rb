class BudgetItemSaver
  def save_item_data(budget_item, data)
    self.budget_item = budget_item
    extract_data(data)

    return unless budget_item.present?

    save_code
    save_name

    def save_possible_duplicates?
      item_is_new && budget_item.respond_to?(:save_possible_duplicates)
    end
  end

  attr_accessor :budget_item,
                :start_date,
                :code_number,
                :name_text

  private

  def extract_data(data)
    self.start_date = data[:start_date]
    self.code_number = data[:code_number]
    self.name_text = data[:name_text]
  end

  def save_code
    budget_item.add_code(
      code_number: code_number
    )
  end

  def save_name
    budget_item.add_name(
      nameable: budget_item,
      text_ka: name_text,
      text_en: '',
      start_date: start_date
    )
  end
end
