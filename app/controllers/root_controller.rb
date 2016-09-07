# Non-resource pages
class RootController < ApplicationController
  def index
  end

  def explore
    @programs = Program.all
  end

  def about
  end
end
