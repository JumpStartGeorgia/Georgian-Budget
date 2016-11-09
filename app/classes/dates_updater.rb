class DatesUpdater
  def initialize(target_item, updater_item)
    @target_item = target_item
    @updater_item = updater_item
  end

  def update
    process_start_dates
    process_end_dates
  end

  attr_reader :target_item
  attr_reader :updater_item

  private

  def process_start_dates
    return unless update_target_item_start_date?

    target_item.update_column(:start_date, updater_item.start_date)
  end

  def update_target_item_start_date?
    return false unless target_item.respond_to?(:start_date)
    return false unless updater_item.respond_to?(:start_date)
    return false if updater_item.start_date.nil?
    return true if target_item.start_date.nil?
    return false if target_item.start_date <= updater_item.start_date

    true
  end

  def process_end_dates
    return unless update_target_item_end_date?

    target_item.update_column(:end_date, updater_item.end_date)
  end

  def update_target_item_end_date?
    return false unless target_item.respond_to?(:end_date)
    return false unless updater_item.respond_to?(:end_date)
    return false if updater_item.end_date.nil?
    return true if target_item.end_date.nil?
    return false if target_item.end_date >= updater_item.end_date

    true
  end
end
