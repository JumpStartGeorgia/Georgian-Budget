# Non-resource pages
class RootController < ApplicationController
  def index
  end

  def explore
    @programs = Program.all.with_most_recent_names
    @priorities = Priority.all.with_most_recent_names
    @spending_agencies = SpendingAgency.all.with_most_recent_names
  end

  def about
  end

  def temp_nameable_show
    nameable_type = params[:nameable_type].to_sym

    if nameable_type == :program
      @nameable = Program.find(params[:nameable_id])
    end

    if nameable_type == :spending_agency
      @nameable = SpendingAgency.find(params[:nameable_id])
    end

    if nameable_type == :priority
      @nameable = Priority.find(params[:nameable_id])
    end
  end

  def api
    response = {
      budget_items: params['budgetItemIds'].map { |id| chart_config_for_program(id) }
    }

    render json: response, status: :ok
  end

  private

  def chart_config_for_program(id)
    budget_item = Program.find(id)
    spent_finances = budget_item.spent_finances.with_missing_finances.sort_by { |finance| finance.start_date }

    name = budget_item.name

    time_period_months = spent_finances.map(&:month).map { |month| month.strftime('%B, %Y') }

    amounts = spent_finances.map(&:amount).map do |amount|
      amount.present? ? amount.to_f : nil
    end

    {
      name: name,
      time_periods: time_period_months,
      amounts: amounts
    }
  end
end
