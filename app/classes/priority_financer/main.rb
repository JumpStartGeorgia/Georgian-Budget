class PriorityFinancer::Main
  attr_reader :priority

  def initialize(priority)
    @priority = priority
  end

  def update_finances
    PriorityFinancer::Spent.new(priority).update_from(
      directly_connected_spent_finances)

    PriorityFinancer::Planned.new(priority).update_planned_finances
  end

  def directly_connected_spent_finances
    Finances::DirectlyConnectedToPriorityQuery.new(priority, SpentFinance).call
  end
end
