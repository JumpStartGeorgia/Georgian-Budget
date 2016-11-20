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

  def save_possible_duplicates(possible_duplicates, args)
    date_when_found = args[:date_when_found]

    possible_duplicates.each do |possible_duplicate_item|
      PossibleDuplicatePair.create(
        items: [possible_duplicate_item, self],
        date_when_found: date_when_found
      )
    end
  end

  def take_possible_duplicates_from(old_duplicatable)
    PossibleDuplicatePair.where(item1: old_duplicatable).update(item1: self)
    PossibleDuplicatePair.where(item2: old_duplicatable).update(item2: self)
  end
end
