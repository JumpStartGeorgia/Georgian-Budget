module PermaIdable
  extend ActiveSupport::Concern

  included do
    has_many :perma_ids,
             as: :perma_idable,
             dependent: :destroy
  end

  def save_perma_id(perma_id_text)
    PermaId.create(
      text: perma_id_text,
      perma_idable: self
    )
  end

  def compute_perma_id
    PermaIdCreator.for_budget_item(self).compute
  end
end
