module Codeable
  extend ActiveSupport::Concern

  included do
  end

  def add_code(args)
    self[:code] = args[:code_number]
    save!

    self
  end
end
