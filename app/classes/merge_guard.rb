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
    enforce_items_diffent_types
    enforce_monthly_spent_correctly_ordered
    enforce_monthly_planned_correctly_ordered
  end

  private

  def enforce_items_are_different
    return unless item1 == item2
    raise MergeImpossibleError, "Item 1 (#{item1_id}) is the same as item 2"
  end

  def enforce_items_diffent_types
    return if item1.class == item2.class
    raise MergeImpossibleError, "Item 1 (#{item1_id}) type #{item1.class} is different from item 2 (#{item2_id}) type #{item2.class}"
  end

  def enforce_monthly_spent_correctly_ordered
    return if spent_monthly_correctly_ordered?

    raise MergeImpossibleError, "Item 1 (#{item1_id}) has monthly spent finances after item 2 (#{item2_id})"
  end

  def enforce_monthly_planned_correctly_ordered
    return if planned_quarterly_correctly_ordered?

    raise MergeImpossibleError, "Item 1 (#{item1_id}) has quarterly planned finances after item 2 (#{item2_id})"
  end

  def spent_monthly_correctly_ordered?
    item1_end_date = item1.all_spent_finances.monthly.maximum(:end_date)
    return true if item1_end_date.blank?

    item2_start_date = item2.all_spent_finances.monthly.minimum(:start_date)
    return true if item2_start_date.blank?

    item1_end_date <= item2_start_date
  end

  def planned_quarterly_correctly_ordered?
    item1_end_date = item1.all_planned_finances.quarterly.maximum(:end_date)
    return true if item1_end_date.blank?

    item2_start_date = item2.all_planned_finances.quarterly.minimum(:start_date)
    return true if item2_start_date.blank?

    item1_end_date <= item2_start_date
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
