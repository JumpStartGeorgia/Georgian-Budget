# Non-resource pages
class RootController < ApplicationController
  def index
  end

  def explore
    @programs = Program.all
    @priorities = Priority.all
    @spending_agencies = SpendingAgency.all
  end

  def about
  end
end
