module Nameable
  extend ActiveSupport::Concern

  included do
    has_many :names, as: :nameable
  end

  def name
    names.order('start_date').last.text
  end

  module ClassMethods
    def find_by_name(name)
      joins(names: :translations)
      .where('name_translations.text = ?', name)
    end
  end
end
