class ItemOverlapGuard
  attr_reader :item1, :item2

  def initialize(item1, item2)
    @item1 = item1
    @item2 = item2
  end

  def overlap?
    official_spent_finances_yearly_overlap.present? ||
    official_spent_finances_monthly_overlap.present?
  end

  private

  def official_spent_finances_yearly_overlap
    item1_official_spent = item1.spent_finances.yearly.official
    item2_official_spent = item2.spent_finances.yearly.official

    return [] if item1_official_spent.blank?
    return [] if item2_official_spent.blank?

    finances_overlap(item1_official_spent, item2_official_spent)
  end

  def official_spent_finances_monthly_overlap
    item1_official_spent = item1.spent_finances.monthly.official
    item2_official_spent = item2.spent_finances.monthly.official

    return [] if item1_official_spent.blank?
    return [] if item2_official_spent.blank?

    finances_overlap(item1_official_spent, item2_official_spent)
  end

  def finances_overlap(finances1, finances2)
    periods1 = finances1.map(&:time_period_obj)
    periods2 = finances2.map(&:time_period_obj)

    periods1 & periods2
  end
end
