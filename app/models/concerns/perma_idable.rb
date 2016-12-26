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

    update_with_new_perma_id if new_perma_id.persisted?

    self
  end

  def take_perma_id(new_perma_id)
    new_perma_id.update_attribute(:perma_idable, self)

    update_with_new_perma_id if new_perma_id.persisted?
  end

  def update_with_new_perma_id
    update_attribute(:perma_id, perma_ids.last.text)
  end

  private

  def compute_perma_id
    PermaIdCreator.new(Hash.new.tap do |hash|
      hash[:name] = name_ka
      hash[:code] = codes.last.number if respond_to?(:code)
    end).compute
  end
end
