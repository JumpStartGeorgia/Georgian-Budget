# updates a program's spending_agency and parent_program
class ProgramAncestorsUpdater
  def initialize(program)
    @program = program
  end

  def update
    program.update_attributes(
      spending_agency: find_spending_agency,
      parent_program: find_parent_program
    )
  end

  def find_spending_agency
    agency_code.codeable if agency_code.present?
  end

  def find_parent_program
    parent_program_code.codeable if parent_program_code.present?
  end

  attr_reader :program

  private

  def code
    @code ||= program.codes.last
  end

  def parent_program_code
    return nil if parent_program_code_number.nil?

    # Code.find_by_number(parent_program_code_number)
    Code.where(number: parent_program_code_number).order('start_date desc').first
  end

  def parent_program_code_number
    return nil if code.number_parts.count == 2

    code.number_parts[0..(code.number_parts.length - 2)].join(' ')
  end

  def agency_code
    # Code.find_by_number(agency_code_number)
    Code.where(number: agency_code_number).order('start_date desc').first
  end

  def agency_code_number
    "#{code.number_parts[0]} 00"
  end
end
