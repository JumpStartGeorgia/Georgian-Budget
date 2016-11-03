class BudgetItemFetcher
  def initialize
    self.created_new_item = false
  end

  def fetch(args)
    self.code_number = args[:code_number]

    return nil unless klass.present?

    if klass == Total
      if Total.first.present?
        return Total.first
      end

      return create_item
    end

    return Total.first if klass == Total && Total.first.present?

    name_text = args[:name_text]

    item = klass.where(code: code_number).find do |possible_item|
      Name.texts_represent_same_budget_item?(name_text, possible_item.name)
    end

    return item if item.present?
    return nil unless args[:create_if_nil]

    create_item
  end

  attr_reader :created_new_item

  private

  attr_writer :created_new_item

  attr_accessor :code_number

  def create_item
    item = klass.create!
    self.created_new_item = true
    item
  end

  def klass
    @klass ||= BudgetCodeMapper.class_for_code(code_number)
  end
end
