module PermaIdable
  extend ActiveSupport::Concern

  included do
    has_many :perma_ids,
             as: :perma_idable,
             dependent: :destroy
  end

  def perma_id
    perma_ids.last
  end

  def save_perma_id(args = {})
    text = args[:override_text].present? ?
           args[:override_text] :
           compute_perma_id

    PermaId.create(
      text: text,
      perma_idable: self
    )
  end

  private

  def compute_perma_id
    PermaIdCreator.for_budget_item(self).compute
  end
end
