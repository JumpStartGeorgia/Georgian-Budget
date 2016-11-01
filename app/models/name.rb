class Name < ApplicationRecord
  belongs_to :nameable, polymorphic: true

  translates :text, fallbacks_for_empty_translations: true
  globalize_accessors locales: [:en, :ka], attributes: [:text]

  validates :start_date, uniqueness: { scope: [:nameable_type, :nameable_id] }, presence: true
  validates :nameable, presence: true

  def merge_more_recent_name(more_recent_name)
    return false if more_recent_name.nil?
    update_column(:is_most_recent, more_recent_name.is_most_recent)

    more_recent_name.destroy

    return true
  end
end
