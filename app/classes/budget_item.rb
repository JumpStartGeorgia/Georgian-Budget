class BudgetItem
  def self.find_by_perma_id(perma_id_text)
    perma_id = PermaId.find_by_text(perma_id_text)

    perma_id.present? ? perma_id.perma_idable : nil
  end
end
