class BudgetItemFetcher
  def fetch(args)
    klass = args[:klass]
    name_text = args[:name_text]
    primary_code = args[:code_number]

    return Total.first if klass == Total

    item = klass.where(code: primary_code).find do |possible_item|
      Name.texts_represent_same_budget_item?(name_text, possible_item.name)
    end

    return item if item.present?
    nil
  end
end
