class BudgetDataSaver
  def initialize(data_holder)
    @data_holder = data_holder
  end

  def save_data
    save_code
    save_name
    save_spent_finance
    save_planned_finance
    save_perma_id

    exact_match = DuplicateFinder.new(new_item).find_exact_match

    if exact_match.present?
      merge_items(exact_match)
    else
      if new_item.respond_to?(:save_possible_duplicates)
        new_item.save_possible_duplicates(
          DuplicateFinder.new(new_item).find_possible_duplicates
        )
      end
    end
  end

  private

  def new_item
    @new_item ||= klass.create
  end

  def klass
    BudgetCodeMapper.class_for_code(data_holder.code_number)
  end

  def save_code
    return unless new_item.respond_to?(:add_code)
    return unless data_holder.respond_to?(:code_data)
    new_item.add_code(data_holder.code_data)
  end

  def save_name
    return unless new_item.respond_to?(:add_name)
    return unless data_holder.respond_to?(:name_data)
    new_item.add_name(data_holder.name_data)
  end

  def save_spent_finance
    return unless data_holder.respond_to?(:spent_finance_data)
    new_item.add_spent_finance(
      data_holder.spent_finance_data
    )
  end

  def save_planned_finance
    return unless data_holder.respond_to?(:planned_finance_data)
    new_item.add_planned_finance(
      data_holder.planned_finance_data
    )
  end

  def save_perma_id
    return unless new_item.respond_to?(:perma_ids)

    new_item.save_perma_id(new_item.compute_perma_id)
  end

  def merge_items(other_item)
    if other_item.start_date.blank? || new_item.start_date.blank?
      ItemMerger.new(other_item).merge(new_item)
    elsif other_item.start_date <= new_item.start_date
      ItemMerger.new(other_item).merge(new_item)
    else
      ItemMerger.new(new_item).merge(other_item)
    end
  end

  attr_reader :data_holder
end
