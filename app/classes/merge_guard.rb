class MergeImpossibleError < StandardError
end

# Raises MergeImpossibleError if there is a problem with merging
# item2 into item1
class MergeGuard
  attr_reader :item1, :item2
  def initialize(item1, item2)
    @item1 = item1
    @item2 = item2
  end

  def enforce_merge_okay
    enforce_items_are_different
    enforce_items_have_same_type
  end

  private

  def enforce_items_are_different
    return unless item1 == item2
    raise MergeImpossibleError, "Item 1 (#{item1_id}) is the same as item 2"
  end

  def enforce_items_have_same_type
    return if item1.class == item2.class
    raise MergeImpossibleError, "Item 1 (#{item1_id}) type #{item1.class} is different from item 2 (#{item2_id}) type #{item2.class}"
  end

  def item1_id
    return item1.perma_id if item1.perma_id.present?

    item1.id
  end

  def item2_id
    return item2.perma_id if item2.perma_id.present?

    item2.id
  end
end
