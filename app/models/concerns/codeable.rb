module Codeable
  extend ActiveSupport::Concern

  included do
    has_many :codes, -> { order :start_date }, as: :codeable
  end

  def add_code(code_attributes, args = {})
    transaction do
      code_attributes[:codeable] = self

      new_code = Code.create!(code_attributes)

      merge_new_code(new_code)
      update_column(:code, codes.last.number)
      DatesUpdater.new(self, new_code).update

      args[:return_code] ? new_code : self
    end
  end

  def code_on_date(date)
    codes.where('start_date <= ?', date).last
  end

  private

  def merge_new_code(new_code)
    codes.reload
    return if codes.length == 1

    new_code_index = codes.to_a.index do |sibling|
      sibling.id == new_code.id
    end

    more_recent_sibling = codes[new_code_index + 1]

    if more_recent_sibling.present? && more_recent_sibling.number == new_code.number
      merge_code_siblings(new_code, more_recent_sibling)
    end

    earlier_sibling = codes[new_code_index - 1]

    if new_code_index > 0 && earlier_sibling.number == new_code.number
      merge_code_siblings(new_code, earlier_sibling)
    end
  end

  def merge_code_siblings(code1, code2)
    if code1.start_date <= code2.start_date
      code2.destroy
    else
      code1.destroy
    end
  end
end
