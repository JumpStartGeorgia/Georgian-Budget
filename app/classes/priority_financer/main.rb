class PriorityFinancer::Main
  attr_reader :priority

  def initialize(priority)
    @priority = priority
  end

  def update_finances
    PriorityFinancer::Spent.new(priority).update_spent_finances
    PriorityFinancer::Planned.new(priority).update_planned_finances
  end
end
