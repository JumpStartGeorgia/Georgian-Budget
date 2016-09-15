class Name < ApplicationRecord
  belongs_to :nameable, polymorphic: true

  translates :text,
             fallbacks_for_empty_translations: true

  after_commit :set_nameable_is_most_recent

  def set_nameable_is_most_recent
    nameable.update_names_is_most_recent unless nameable.nil?
  end
end
