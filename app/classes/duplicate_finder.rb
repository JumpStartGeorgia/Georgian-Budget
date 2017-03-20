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
      return possible_item if is_exact_match?(possible_item)
    end

    items_with_same_code.each do |possible_item|
      return possible_item if is_exact_match?(possible_item)
    end

    nil
  end

  def find_possible_duplicates
    items_with_same_code
    .order(start_date: :desc)
    .select do |possible_item|
      is_possible_duplicate?(possible_item)
    end
  end

  def is_possible_duplicate?(other_item)
    return false if other_item.start_date.present? && source_item.end_date.present? && other_item.start_date > source_item.end_date
    return false if items_overlap?(other_item)
    return true if code_matches?(other_item)
    return true if name_matches?(other_item)

    false
  end

  private

  def items_with_same_code
    @items_with_same_code ||= source_item.class
    .with_code_in_history(source_item.code)
    .where.not(id: source_item)
  end

  def items_with_same_name
    @items_with_same_name ||= source_item.class
    .with_name_in_history(source_item.name)
    .where.not(id: source_item)
  end

  def is_exact_match?(other_item)
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
    other_item.codes.pluck(:number).include? source_item.codes.last.number
  end

  attr_reader :source_item
end
