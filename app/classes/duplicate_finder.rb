class DuplicateFinder
  def initialize(source_item)
    @source_item = source_item
  end

  def find
    @exact_match = nil
    @possible_duplicates = []

    find_exact_match

    return {
      exact_match: exact_match,
      possible_duplicates: possible_duplicates
    }
  end

  private

  def find_exact_match
    items_with_same_code = source_item.class
    .where(code: source_item.code)
    .where.not(id: source_item)

    items_with_same_name = source_item.class
    .find_by_name(source_item.name)
    .where.not(id: source_item)

    possible_items = items_with_same_code + items_with_same_name

    possible_items.each do |possible_item|
      if is_duplicate?(possible_item)
        self.exact_match = possible_item
      elsif is_possible_duplicate?(possible_item)
        possible_duplicates << possible_item
      end
    end
  end

  def is_duplicate?(other_item)
    return false unless name_matches?(other_item)
    return false unless source_item.class == SpendingAgency || code_matches?(other_item)

    true
  end

  def is_possible_duplicate?(other_item)
    return true if name_matches?(other_item)
    return true if code_matches?(other_item)

    false
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

  attr_reader :source_item, :possible_duplicates
  attr_accessor :exact_match
end
