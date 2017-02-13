class BudgetDataSaver
  def initialize(data_holder)
    @data_holder = data_holder
  end

  def save_data
    save_code
    save_name
    save_spent_finance
    save_planned_finances
    save_perma_id
    save_dates
    save_priority_connection

    duplicate_finder = DuplicateFinder.new(new_item)
    exact_match = duplicate_finder.find_exact_match

    if exact_match.present?
      merge_items(exact_match)
    else
      if new_item.respond_to?(:save_possible_duplicates)
        new_item.save_possible_duplicates(
          duplicate_finder.find_possible_duplicates,
          date_when_found: data_holder.publish_date
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
    return unless data_holder.spent_finance_data.present?

    new_item.add_spent_finance(data_holder.spent_finance_data)
  end

  # if there is just one planned finance hash (monthly spreadsheets), this
  # method saves it. if there are multiple hashes (yearly spreadsheets),
  # this method saves all of them.
  def save_planned_finances
    return unless data_holder.respond_to?(:planned_finance_data)
    return unless data_holder.planned_finance_data.present?

    planned_finance_data = data_holder.planned_finance_data

    unless planned_finance_data.is_a? Array
      planned_finance_data = [planned_finance_data]
    end

    planned_finance_data.each do |planned_finance_data_hash|
      new_item.add_planned_finance(planned_finance_data_hash)
    end
  end

  def save_perma_id
    return unless new_item.respond_to?(:perma_ids)

    new_item.save_perma_id
  end

  def save_dates
    return unless data_holder.respond_to?(:end_date) || data_holder.respond_to?(:start_date)

    DatesUpdater.new(new_item, data_holder).update
  end

  def save_priority_connection
    return unless data_holder.respond_to?(:priority_connection_data)

    PriorityConnector.new(
      new_item,
      data_holder.priority_connection_data
    ).connect
  end

  def merge_items(other_item)
    ItemMerger.new(other_item).merge(new_item)
  end

  attr_reader :data_holder
end
