class Name < ApplicationRecord
  belongs_to :nameable, polymorphic: true

  translates :text,
             fallbacks_for_empty_translations: true
end
