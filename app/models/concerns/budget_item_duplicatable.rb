module BudgetItemDuplicatable
  extend ActiveSupport::Concern

  included do
    has_many :subsequent_possible_duplicate_pairs,
             class_name: 'PossibleDuplicatePair',
             as: :item1,
             foreign_type: 'pair_type',
             dependent: :destroy

    has_many :subsequent_possible_duplicates,
             through: :subsequent_possible_duplicate_pairs,
             source: :item2,
             source_type: self.to_s

    has_many :earlier_possible_duplicate_pairs,
             class_name: 'PossibleDuplicatePair',
             as: :item2,
             foreign_type: 'pair_type',
             dependent: :destroy

    has_many :earlier_possible_duplicates,
             through: :earlier_possible_duplicate_pairs,
             source: :item1,
             source_type: self.to_s
  end

  def possible_duplicates
    earlier_possible_duplicates + subsequent_possible_duplicates
  end

  def save_possible_duplicates(possible_duplicates)
    possible_duplicates.each do |possible_duplicate_item|
      PossibleDuplicatePair.create(
        items: [possible_duplicate_item, self]
      )
    end
  end

  def get_possible_duplicates
    possible_duplicates_array = []

    code_duplicate = self.class.where(code: code).where.not(id: self).order(:start_date).last
    possible_duplicates_array << code_duplicate if code_duplicate.present?

    name_duplicate = self.class.find_by_name(name).where.not(id: self).order(:start_date).last
    possible_duplicates_array << name_duplicate if name_duplicate.present?

    possible_duplicates_array
  end
end
