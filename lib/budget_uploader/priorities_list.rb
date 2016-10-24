class PrioritiesList
  def self.new_from_file(file_path)
    require 'csv'
    self.new(CSV.read(file_path))
  end

  def initialize(rows)
    @rows = rows
  end

  def save
    rows.each do |row|
      create_priority_from_row(row)
    end
  end

  attr_reader :rows

  private

  def create_priority_from_row(row)
    priority = Priority.create

    Name.create(
      start_date: Date.new(2012, 1, 1),
      text_ka: row[0],
      nameable: priority
    )
  end
end
