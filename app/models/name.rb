class Name < ApplicationRecord
  belongs_to :nameable, polymorphic: true

  translates :text,
             fallbacks_for_empty_translations: true

  validates :start_date, uniqueness: { scope: :nameable }, presence: true
  validates :nameable, presence: true
  
  after_commit :set_nameable_is_most_recent

  def set_nameable_is_most_recent
    nameable.update_names unless nameable.nil?
  end

  def merge_more_recent_name(more_recent_name)
    return false if more_recent_name.nil?
    update_column(:is_most_recent, more_recent_name.is_most_recent)

    more_recent_name.destroy

    return true
  end
end
