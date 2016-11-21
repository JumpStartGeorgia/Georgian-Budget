class ItemOverlapGuard
  def initialize(item1, item2)
    @item1 = item1
    @item2 = item2
  end

  def overlap?
    return true if spent_finances_overlap?

    false
  end

  attr_reader :item1, :item2

  private

  def spent_finances_overlap?
    item1_official_spent = item1.spent_finances.official
    item2_official_spent = item2.spent_finances.official

    return false if item1_official_spent.blank?
    return false if item2_official_spent.blank?

    periods1 = item1_official_spent.map(&:time_period).map(&:to_s)
    periods2 = item2_official_spent.map(&:time_period).map(&:to_s)

    return true if (periods1 & periods2).present?

    false
  end
end
