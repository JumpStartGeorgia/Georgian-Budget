module BudgetItemDuplicatable
  extend ActiveSupport::Concern

  included do
    has_many :possible_duplicate_pairs1,
             class_name: 'PossibleDuplicatePair',
             as: :item1,
             foreign_type: 'pair_type',
             dependent: :destroy

    has_many :possible_duplicates1,
             through: :possible_duplicate_pairs1,
             source: :item2,
             source_type: self.to_s

    has_many :possible_duplicate_pairs2,
             class_name: 'PossibleDuplicatePair',
             as: :item2,
             foreign_type: 'pair_type',
             dependent: :destroy

    has_many :possible_duplicates2,
             through: :possible_duplicate_pairs2,
             source: :item1,
             source_type: self.to_s
  end

  def possible_duplicates
    possible_duplicates1 + possible_duplicates2
  end

  def save_possible_duplicates
    get_possible_duplicates.each do |possible_duplicate_item|
      PossibleDuplicatePair.create(
        item1: possible_duplicate_item,
        item2: self
      )
    end
  end

  private

  def get_possible_duplicates
    possible_duplicates_array = []

    code_duplicate = self.class.where(code: code).where.not(id: self).last
    possible_duplicates_array << code_duplicate if code_duplicate.present?

    name_duplicate = self.class.find_by_name(name).where.not(id: self).last
    possible_duplicates_array << name_duplicate if name_duplicate.present?

    possible_duplicates_array
  end
end
