class ItemOverlapGuard
  def initialize(item1, item2)
    @item1 = item1
    @item2 = item2
  end

  def overlap?
    return true if check_data_with_period_type('monthly')
    return true if check_data_with_period_type('yearly')

    false
  end

  attr_reader :item1, :item2

  private

  def check_data_with_period_type(time_period_type)
    return false if item1.spent_finances.send(time_period_type).blank?
    return false if item2.spent_finances.send(time_period_type).blank?

    item1_start = item1.spent_finances.send(time_period_type).minimum(:start_date)
    item2_start = item1.spent_finances.send(time_period_type).maximum(:end_date)

    other_start = item2.spent_finances.send(time_period_type).minimum(:start_date)
    other_end = item1.spent_finances.send(time_period_type).maximum(:end_date)

    return true if item1_start <= other_end
    return true if item2_start >= other_start

    false
  end
end
