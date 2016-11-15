class PermaId < ApplicationRecord
  belongs_to :perma_idable, polymorphic: true

  validates :text, presence: true, uniqueness: true
  validates :perma_idable, presence: true
end
