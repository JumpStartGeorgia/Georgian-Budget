class ItemOverlapGuard
  def initialize(item1, item2)
    @item1 = item1
    @item2 = item2
  end

  def overlap?
    return true if finances_overlap?(
      item1.spent_finances.official,
      item2.spent_finances.official)

    false
  end

  attr_reader :item1, :item2

  private

  def finances_overlap?(item1_official_spent, item2_official_spent)
    return false if item1_official_spent.blank?
    return false if item2_official_spent.blank?

    periods1 = item1_official_spent.map(&:time_period).map(&:to_s)
    periods2 = item2_official_spent.map(&:time_period).map(&:to_s)

    return true if (periods1 & periods2).present?

    false
  end
end
