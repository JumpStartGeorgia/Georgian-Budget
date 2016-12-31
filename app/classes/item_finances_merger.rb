# This class takes two budget items, say program A and program B, and
# moves the finances of type finance_model that belong to one into the other.

# The complex part of this merging is due to the cumulative nature of some
# finances. The Georgian government's monthly budget spreadsheets list
# values cumulatively, which means that monthly spent finances are cumulative
# and quarterly planned finances are cumulative. (Cumulative within
# the given year.)

# We prefer to save the non-cumulative amounts. Doing so, however, requires
# knowing what the previous amounts in a certain year are. If you are
# using this class to merge program A and program B, then presumably
# they are in reality the same program; however, before the merge, they
# did not know about each other and therefore did not calculate
# their non cumulative amounts correctly. This class will update
# finance amounts as necessary so that they are no longer cumulative.
# For details on how this works, see the spec.
class ItemFinancesMerger
  attr_reader :receiver, :giver, :finances_model

  def initialize(receiver, giver, finances_model)
    @receiver = receiver
    @giver = giver
    @finances_model = finances_model
  end

  def merge
    deaccumulate_cumulative_finances

    giver_all_finances.each do |finance|
      receiver_take(finance)
    end
  end

  private

  def deaccumulate_cumulative_finances
    return [] if giver_all_finances_cumulative_period_type.blank?

    years_containing_cumulative_finances.each do |year|
      deaccumulate_cumulative_finances_in(year)
    end.flatten
  end

  def years_containing_cumulative_finances
    Year.for_dates(giver_all_finances_cumulative_period_type.pluck(:start_date))
  end

  def deaccumulate_cumulative_finances_in(year)
    primary_finances_in_year = finances_model
    .where(id:
      receiver_all_finances_cumulative_period_type +
      giver_all_finances_cumulative_period_type)
    .primary
    .within_time_period(year)
    .order(:start_date)

    primary_cumulative_finances = []

    primary_finances_in_year.each_with_index do |finance, index|
      next if index == 0
      next if finance.budget_item == primary_finances_in_year[index - 1].budget_item

      primary_cumulative_finances << finance
    end

    primary_cumulative_finances.each do |primary_cumulative_finance|
      extra_amount = amount_to_remove_from_finance(
        primary_cumulative_finance
      )

      primary_cumulative_finance
      .versions
      .each do |version|
        version.update_attributes(amount: version.amount - extra_amount)
      end
    end
  end

  def giver_all_finances_cumulative_period_type
    giver_all_finances.public_send(finance_model_cumulative_period_type)
  end

  def receiver_all_finances_cumulative_period_type
    receiver_all_finances.public_send(finance_model_cumulative_period_type)
  end

  def giver_all_finances
    giver.public_send(all_finances_association)
  end

  def receiver_all_finances
    receiver.public_send(all_finances_association)
  end

  def amount_to_remove_from_finance(finance)
    other_budget_item(finance)
    .send(finances_association)
    .after(preceding_date_in_year(finance))
    .before(finance.start_date)
    .sum(:amount)
  end

  def preceding_date_in_year(finance)
    year = Year.for_date(finance.start_date)

    finances_in_same_year = finance
    .siblings
    .where(time_period_type: finance.time_period_type)
    .within_time_period(year)
    .to_a

    index = finances_in_same_year.index(finance)

    if index == 0
      year.start_date
    else
      finances_in_same_year[index - 1].end_date
    end
  end

  def receiver_take(finance)
    if finances_model == PlannedFinance
      receiver.take_planned_finance(finance)
    elsif finances_model == SpentFinance
      receiver.take_spent_finance(finance)
    end
  end

  def other_budget_item(finance)
    finance.budget_item == receiver ? giver : receiver
  end

  def finance_model_cumulative_period_type
    if finances_model == PlannedFinance
      'quarterly'
    elsif finances_model == SpentFinance
      'monthly'
    end
  end

  def finances_association
    if finances_model == PlannedFinance
      'planned_finances'
    elsif finances_model == SpentFinance
      'spent_finances'
    end
  end

  def all_finances_association
    if finances_model == PlannedFinance
      'all_planned_finances'
    elsif finances_model == SpentFinance
      'all_spent_finances'
    end
  end
end
