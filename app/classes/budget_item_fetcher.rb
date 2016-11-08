class BudgetItemFetcher
  def initialize
    self.created_new_item = false
  end

  def fetch(args)
    self.code_number = args[:code_number]
    self.name_text = args[:name_text]
    self.create_if_nil = args[:create_if_nil]

    return nil unless klass.present?

    item = fetch_created_item
    return item if item.present?
    return nil unless create_if_nil

    create_item
  end

  attr_reader :created_new_item

  private

  attr_writer :created_new_item

  attr_accessor :code_number,
                :name_text,
                :create_if_nil

  def fetch_created_item
    return fetch_or_create_total if klass == Total

    item = fetch_by_code
    return item if item.present?

    item = fetch_by_name if klass == SpendingAgency
    return item if item.present?

    nil
  end

  def fetch_or_create_total
    return Total.first if Total.first.present?
    return create_item if create_if_nil

    nil
  end

  def fetch_by_code
    klass.where(code: code_number).find do |possible_item|
      Name.texts_represent_same_budget_item?(name_text, possible_item.name)
    end
  end

  def fetch_by_name
    klass.find_by_name(name_text).last
  end

  def create_item
    item = klass.create!
    self.created_new_item = true
    item
  end

  def klass
    @klass ||= BudgetCodeMapper.class_for_code(code_number)
  end
end
