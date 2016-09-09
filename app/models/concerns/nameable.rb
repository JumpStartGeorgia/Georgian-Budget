module Nameable
  extend ActiveSupport::Concern

  included do
    has_many :names, as: :nameable
  end

  def name
    names.sort_by(&:start_date).last.text
  end

  module ClassMethods
    def find_by_name(name)
      joins(names: :translations)
      .where('name_translations.text = ?', name)
    end

    def with_most_recent_names
      includes(names: :translations)
    end
  end
end
