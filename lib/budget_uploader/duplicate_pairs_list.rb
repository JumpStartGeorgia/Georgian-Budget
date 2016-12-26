class DuplicatePairsList
  attr_reader :file_path

  def initialize(file_path)
    @file_path = file_path
  end

  def process
    require('csv')
    CSV.read(file_path).each_with_index do |row, index|
      next if index === 0

      process_row(row)
    end
  end

  private

  def process_row(row)
    return if item1(row).blank?
    return if item2(row).blank?
    return if pair(row).blank?

    if merge_items?(row)
      pair(row).resolve_as_duplicates
    else
      pair(row).resolve_as_non_duplicates
    end
  end

  def pair(row)
    PossibleDuplicatePair.where(
      item1: item1(row),
      item2: item2(row))
    .first
  end

  def item1(row)
    BudgetItem.find_by_perma_id(item1_perma_id(row))
  end

  def item2(row)
    BudgetItem.find_by_perma_id(item2_perma_id(row))
  end

  def merge_items?(row)
    row[0] == 'yes'
  end

  def item1_perma_id(row)
    row[2]
  end

  def item2_perma_id(row)
    row[3]
  end
end
