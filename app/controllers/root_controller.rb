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
end
