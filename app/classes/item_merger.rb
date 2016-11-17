class ItemMerger
  def initialize(receiver)
    @receiver = receiver
  end

  def merge(giver)
    unless receiver.class == giver.class
      raise "Merging #{giver.class} into #{receiver.class} is not allowed; types must be the same"
    end

    if receiver_after_giver?(giver)
      raise "Cannot merge earlier item into later item; receiver must start before giver"
    end

    merge_priority(giver.priority) if receiver.respond_to?(:priority)
    merge_codes(giver.codes) if receiver.respond_to?(:take_code)
    merge_names(giver.names) if receiver.respond_to?(:take_name)

    if receiver.respond_to?(:take_spent_finance)
      merge_spent_finances(giver.spent_finances)
    end

    if receiver.respond_to?(:take_planned_finance)
      merge_planned_finances(giver.all_planned_finances)
    end

    if receiver.respond_to?(:child_programs)
      merge_child_programs(giver.child_programs)
    end

    if receiver.respond_to?(:save_possible_duplicates)
      merge_possible_duplicates(giver.possible_duplicates)
    end

    if receiver.respond_to?(:perma_ids)
      merge_perma_ids(giver.perma_ids)
    end

    giver.reload.destroy
  end

  private

  attr_reader :receiver

  def receiver_after_giver?(giver)
    receiver.respond_to?(:start_date) &&
    giver.respond_to?(:start_date) &&
    receiver.start_date.present? &&
    giver.start_date.present? &&
    receiver.start_date > giver.start_date
  end

  def merge_priority(new_priority)
    return if new_priority.nil?

    if receiver.priority == nil
      receiver.priority = new_priority
      receiver.save!
    else
      raise 'Cannot merge object with different priority' if receiver.priority != new_priority
    end
  end

  def merge_codes(new_codes)
    return if new_codes.blank?

    new_codes.each do |new_code|
      receiver.take_code(new_code)
    end
  end

  def merge_names(new_names)
    return if new_names.blank?

    new_names.each do |new_name|
      receiver.take_name(new_name)
    end
  end

  def merge_spent_finances(new_spent_finances)
    return if new_spent_finances.blank?

    cumulative_within_year = [new_spent_finances.monthly.first]

    new_spent_finances.each do |new_spent_finance|
      calculate_cumulative = cumulative_within_year.include?(new_spent_finance)

      receiver.take_spent_finance(
        new_spent_finance,
        cumulative_within: calculate_cumulative ? Year : nil
      )
    end
  end

  def merge_planned_finances(new_planned_finances)
    return if new_planned_finances.blank?

    first_new_quarter_plan = new_planned_finances.quarterly.first

    cumulative_within_year = first_new_quarter_plan.blank? ? []
      : new_planned_finances.with_time_period(first_new_quarter_plan.time_period)

    new_planned_finances.each do |new_planned_finance|
      calculate_cumulative = cumulative_within_year.include?(new_planned_finance)

      receiver.take_planned_finance(
        new_planned_finance,
        cumulative_within: calculate_cumulative ? Year : nil
      )
    end
  end

  def merge_possible_duplicates(new_possible_duplicates)
    return if new_possible_duplicates.blank?

    receiver.save_possible_duplicates(new_possible_duplicates)
  end

  def merge_child_programs(new_child_programs)
    return if new_child_programs.blank?

    new_child_programs.each do |new_child_program|
      new_child_program.update_attribute(:parent, receiver)
    end
  end

  def merge_perma_ids(new_perma_ids)
    return if new_perma_ids.blank?

    new_perma_ids.each do |new_perma_id|
      receiver.take_perma_id(new_perma_id)
    end
  end
end
