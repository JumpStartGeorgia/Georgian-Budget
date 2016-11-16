module PermaIdable
  extend ActiveSupport::Concern

  included do
    has_many :perma_ids,
             as: :perma_idable,
             dependent: :destroy
  end

  def save_perma_id(args = {})
    text = args[:override_text].present? ?
           args[:override_text] :
           compute_perma_id

    new_perma_id = PermaId.create(
      text: text,
      perma_idable: self
    )

    update_attribute(:perma_id, new_perma_id.text) if new_perma_id.persisted?

    self
  end

  private

  def compute_perma_id
    PermaIdCreator.new(Hash.new.tap do |hash|
      hash[:name] = name_ka
      hash[:code] = code if respond_to?(:code)
    end).compute
  end
end
