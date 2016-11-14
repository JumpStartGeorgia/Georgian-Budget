class Code < ApplicationRecord
  belongs_to :codeable, polymorphic: true

  validates :start_date, presence: true
  validates :number, presence: true
  validates :codeable, presence: true

  def parent_codeable
    parent_codeable_code = parent_code
    parent_codeable_code.present? ? parent_codeable_code.codeable : nil
  end

  def parent_code
    return nil if parent_code_number.nil?

    Code.where(number: parent_code_number)
    .where('start_date <= ?', start_date)
    .order(:start_date).last
  end

  private

  def parent_code_number
    if represents_top_level_program?
      parent_agency_number = [number_parts[0], '00'].join(' ')
      return parent_agency_number
    end

    if represents_child_program?
      parent_program_number = number_parts[0..(number_parts.length - 2)].join(' ')
      return parent_program_number
    end

    nil
  end

  def number_parts
    number.split(' ')
  end

  def represents_top_level_program?
    number_parts.count == 2 && number_parts[1] != '00'
  end

  def represents_child_program?
    number_parts.count >= 3
  end
end
