class PossibleDuplicatePair < ApplicationRecord
  belongs_to :item1, polymorphic: true, foreign_type: 'pair_type'
  belongs_to :item2, polymorphic: true, foreign_type: 'pair_type'

  validates :item1_id, presence: true

  validates :item2_id,
            presence: true,
            uniqueness: {
              scope: [
                :pair_type,
                :item1_id
              ]
            }

  validate :validate_item2_is_not_item1
  validate :validate_items_have_same_type
  validate :validate_does_not_have_equivalent_but_reversed_pair

  def items=(items)
    if items[0].start_date.blank? || items[1].start_date.blank?
      self.item1 = items[0]
      self.item2 = items[1]
      return
    elsif items[0].start_date < items[1].start_date
      earlier_item = items[0]
      later_item = items[1]
    else
      earlier_item = items[1]
      later_item = items[0]
    end

    self.item1 = earlier_item
    self.item2 = later_item
  end

  def date_when_found
    item2.codes.first.start_date
  end

  def item1_code_when_found
    code = item1.code_on_date(date_when_found - 1)
    return code.number if code.present?

    code = item1.code_on_date(date_when_found)
    return code.number if code.present?

    nil
  end

  def item1_name_when_found
    name = item1.name_on_date(date_when_found - 1)
    return name.text if name.present?

    name = item1.name_on_date(date_when_found)
    return name.text if name.present?

    nil
  end

  def item2_code_when_found
    item2.code_on_date(date_when_found).number
  end

  def item2_name_when_found
    item2.name_on_date(date_when_found).text
  end

  def priorities_differ?
    item1.priority.present? &&
    item2.priority.present? &&
    item1.priority != item2.priority
  end

  private

  def validate_item2_is_not_item1
    if (item1_id == item2_id)
      errors.add(:item2_id, 'cannot be the same as item1')
    end
  end

  def validate_items_have_same_type
    if (item1.class != item2.class)
      errors.add(:item2_id, 'must have the same type as item1')
    end
  end

  def validate_does_not_have_equivalent_but_reversed_pair
    if PossibleDuplicatePair.where(item1: item2, item2: item1).present?
      errors.add(:item2_id, 'and item1_id match previously saved pair but reversed')
    end
  end
end
