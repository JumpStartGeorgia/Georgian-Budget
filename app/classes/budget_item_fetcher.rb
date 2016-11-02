class BudgetItemFetcher
  def fetch(args)
    self.code_number = args[:code_number]

    return nil unless klass.present?

    name_text = args[:name_text]

    return Total.first if klass == Total && Total.first.present?

    item = klass.where(code: code_number).find do |possible_item|
      Name.texts_represent_same_budget_item?(name_text, possible_item.name)
    end

    return item if item.present?
    return nil unless args[:create_if_nil]

    klass.create
  end

  attr_accessor :code_number

  private

  def klass
    @klass ||= BudgetCodeMapper.class_for_code(code_number)
  end
end
