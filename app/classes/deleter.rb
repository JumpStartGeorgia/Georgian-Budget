# Deletes all items from database. Removes items with foreign key constraints
# first, so that Postgres does not prevent deletion.
class Deleter
  def self.delete_all
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
    ApplicationRecord.subclasses.select { |c| !c.abstract_class? }.each(&:delete_all)
  end
end
