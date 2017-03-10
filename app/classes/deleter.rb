# Deletes all items from database. Removes items with foreign key constraints
# first, so that Postgres does not prevent deletion.
class Deleter
  def self.delete_all_budget_data
    Name.find_by_sql('DELETE FROM name_translations')
    
    [
      SpentFinance,
      PlannedFinance,
      PossibleDuplicatePair,
      PriorityConnection,
      PermaId,
      Code,
      Name,
      Program,
      SpendingAgency,
      Priority,
      Total
    ].each(&:delete_all)
  end
end
