class BudgetItem
  def self.find_by_perma_id(perma_id_text)
    perma_id = PermaId.find_by_text(perma_id_text)

    perma_id.present? ? perma_id.perma_idable : nil
  end

  def self.find(attributes)
    return nil if attributes[:name].blank?

    perma_id = PermaId.find_by_text(PermaIdCreator.new(attributes).compute)

    perma_id.present? ? perma_id.perma_idable : nil
  end

  def self.klasses
    [Total, Priority, SpendingAgency, Program]
  end
end
