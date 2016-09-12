module Nameable
  extend ActiveSupport::Concern

  included do
    has_many :names, as: :nameable
  end

  # text of most recent name
  def name
    name_object.text
  end

  # most recent name
  def name_object
    names.sort_by(&:start_date).last
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
