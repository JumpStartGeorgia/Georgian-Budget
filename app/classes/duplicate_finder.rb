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

    items_sharing_data.each do |possible_item|
      return possible_item if is_duplicate?(possible_item)
    end

    nil
  end

  def find_possible_duplicates
    items_sharing_data.select do |possible_item|
      is_possible_duplicate?(possible_item)
    end
  end

  private

  def items_sharing_data
    items_with_same_code = source_item.class
    .where(code: source_item.code)
    .where.not(id: source_item)
    .where(source_item.class.arel_table[:start_date].lteq(source_item.end_date))

    items_with_same_name = source_item.class
    .find_by_name(source_item.name)
    .where.not(id: source_item)
    .where(source_item.class.arel_table[:start_date].lteq(source_item.end_date))

    items_with_same_code + items_with_same_name
  end

  def is_duplicate?(other_item)
    return false unless name_matches?(other_item)
    return false unless code_generation_matches?(other_item)
    return false if items_overlap?(other_item)

    true
  end

  def is_possible_duplicate?(other_item)
    return false if items_overlap?(other_item)
    return true if name_matches?(other_item)
    return true if code_matches?(other_item)

    false
  end

  def items_overlap?(other_item)
    ItemOverlapGuard.new(source_item, other_item).overlap?
  end

  def name_matches?(other_item)
    return false if source_item.name.blank? || other_item.name.blank?

    Name.texts_represent_same_budget_item?(
      source_item.name,
      other_item.name)
  end

  def code_matches?(other_item)
    source_item.code == other_item.code
  end

  def code_generation_matches?(other_item)
    source_item.codes.last.generation == other_item.codes.last.generation
  end

  attr_reader :source_item
end
