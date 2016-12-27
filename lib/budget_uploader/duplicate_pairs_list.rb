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

  def output_unmergeable_pairs
    require('csv')
    CSV.read(file_path).each_with_index do |row, index|
      next if index === 0

      output_if_unmergeable(row, index)
    end
  end

  private

  def output_if_unmergeable(row, index)
    item1 = item1(row)
    item2 = item2(row)
    pair = pair(row)

    messages = []
    if item1.blank?
      messages << 'Cannot find item1'
    end

    if item2.blank?
      messages << 'Cannot find item2'
    end

    if pair.blank?
      messages << 'Cannot find pair'
    end

    if merge_items?(row)
      begin
        MergeGuard.new(item1, item2).enforce_merge_okay
      rescue MergeImpossibleError => e
        messages << e
      end
    end

    return if messages.empty?
    puts "\n Row #{index + 1} (Codes #{row[5]}, #{row[6]}) problems:"
    puts messages.join("\n")
  end

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
