# Non-resource pages
class RootController < ApplicationController
  def index
  end

  def explore
  end

  def list
    @total = Total.first
    @programs = Program.all.with_most_recent_names
    @priorities = Priority.all.with_most_recent_names
    @spending_agencies = SpendingAgency.all.with_most_recent_names
  end

  def about
  end

  def temp_nameable_show
    nameable_type = params[:nameable_type].to_sym

    if nameable_type == :total
      @nameable = Total.first
    end

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
end
