class DuplicateFinder
  def initialize(source_item)
    @source_item = source_item
  end

  def find_exact_match
    return nil if source_item.class == Priority

    if source_item.class == Total
      return Total.first unless source_item == Total.first
      return nil
    end

    perma_id_item = BudgetItem.find(
      code: source_item.code,
      name: source_item.name_ka
    )

    if perma_id_item.present? && perma_id_item != source_item
      return perma_id_item
    end

    items_with_same_name.each do |possible_item|
      return possible_item if is_duplicate?(possible_item)
    end

    items_with_same_code.each do |possible_item|
      return possible_item if is_duplicate?(possible_item)
    end

    nil
  end

  def find_possible_duplicates
    possible_duplicates = []

    item_with_same_code = most_recent_item_with_same_code
    possible_duplicates << item_with_same_code if item_with_same_code.present?

    item_with_same_name = most_recent_item_with_same_name
    possible_duplicates << item_with_same_name if item_with_same_name.present?

    possible_duplicates
  end

  def is_possible_duplicate?(other_item)
    return false if items_overlap?(other_item)
    return true if code_matches?(other_item)
    return true if name_matches?(other_item)

    false
  end

  private

  def most_recent_item_with_same_code
    items_with_same_code
    .order(start_date: :desc)
    .find do |possible_item|
      is_possible_duplicate?(possible_item)
    end
  end

  def items_with_same_code
    @items_with_same_code ||= source_item.class
    .with_code_in_history(source_item.code)
    .where.not(id: source_item)
    .where(source_item.class.arel_table[:start_date].lteq(source_item.end_date))
  end

  def most_recent_item_with_same_name
    items_with_same_name
    .order(start_date: :desc)
    .find do |possible_item|
      is_possible_duplicate?(possible_item)
    end
  end

  def items_with_same_name
    @items_with_same_name ||= source_item.class
    .with_name_in_history(source_item.name)
    .where.not(id: source_item)
    .where(source_item.class.arel_table[:start_date].lteq(source_item.end_date))
  end

  def is_duplicate?(other_item)
    return false unless code_generation_matches?(other_item)
    return false unless name_matches?(other_item)
    return false if items_overlap?(other_item)

    true
  end

  def items_overlap?(other_item)
    ItemOverlapGuard.new(source_item, other_item).overlap?
  end

  def name_matches?(other_item)
    return false if source_item.name.blank? || other_item.name.blank?

    other_item.names.each do |other_name|
      return true if Name.texts_represent_same_budget_item?(
        source_item.name,
        other_name.text)
    end

    false
  end

  def code_matches?(other_item)
    other_item.codes.pluck(:number).include? source_item.code
  end

  def code_generation_matches?(other_item)
    source_item.codes.last.generation == other_item.codes.last.generation
  end

  attr_reader :source_item
end
