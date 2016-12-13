class PrioritiesList
  def self.new_from_file(file_path)
    require 'csv'
    self.new(CSV.read(file_path))
  end

  def initialize(rows)
    @rows = rows
    @priority_names = nil
  end

  def save
    rows.each do |row|
      create_priority_from_row(row)
    end
  end

  def get_priority_from_identifier(identifier)
    name = priority_names[identifier.to_sym]

    unless name.present?
      raise "Priorities list has no priority with identifier #{identifier}"
    end

    BudgetItem.find(name: name)
  end

  attr_reader :rows

  private

  def priority_names
    @priority_names ||= get_priority_names
  end

  def get_priority_names
    hash = {}

    rows.each do |row|
      hash[row_identifier(row).to_sym] = row_name(row)
    end

    hash
  end

  def create_priority_from_row(row)
    priority = Priority.create

    priority.add_name(
      start_date: Date.new(2012, 1, 1),
      text_ka: row_name(row)
    ).save_perma_id
  end

  def row_name(row)
    row[0]
  end

  def row_identifier(row)
    row[1]
  end
end
