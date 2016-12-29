class ItemMerger
  def initialize(receiver)
    @receiver = receiver
  end

  def merge(giver)
    MergeGuard.new(receiver, giver).enforce_merge_okay

    merge_codes(giver.codes) if receiver.respond_to?(:take_code)
    merge_names(giver.names) if receiver.respond_to?(:take_name)

    if receiver.respond_to?(:take_spent_finance)
      ItemFinancesMerger.new(receiver, giver.all_spent_finances).merge
    end

    if receiver.respond_to?(:take_planned_finance)
      ItemFinancesMerger.new(receiver, giver.all_planned_finances).merge
    end

    if receiver.respond_to?(:save_possible_duplicates)
      merge_possible_duplicates_from(giver)
    end

    if receiver.respond_to?(:take_programs_from)
      receiver.take_programs_from(giver)
    end

    if receiver.respond_to?(:perma_ids)
      merge_perma_ids(giver.perma_ids)
    end

    if receiver.respond_to?(:priority_connections)
      merge_priority_connections(giver.priority_connections)
    end

    giver.reload.destroy
  end

  private

  attr_reader :receiver

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

  def merge_possible_duplicates_from(giver)
    return if giver.possible_duplicates.blank?

    receiver.take_possible_duplicates_from(giver)
  end

  def merge_perma_ids(new_perma_ids)
    return if new_perma_ids.blank?

    new_perma_ids.each do |new_perma_id|
      receiver.take_perma_id(new_perma_id)
    end
  end

  def merge_priority_connections(priority_connections)
    return if priority_connections.blank?

    priority_connections.update(priority_connectable: receiver)
  end
end
