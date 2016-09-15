module Nameable
  extend ActiveSupport::Concern

  included do
    has_many :names, as: :nameable, dependent: :destroy
  end

  # text of most recent name
  def name
    recent_name_object.text
  end

  # most recent name
  def recent_name_object
    names.sort_by(&:start_date).last
  end

  def update_names_is_most_recent
    names.update_all(is_most_recent: false)
    recent_name_object.update_column(:is_most_recent, true)

    return true
  end

  module ClassMethods
    def find_by_name(name)
      joins(names: :translations)
      .where('name_translations.text = ?', name)
    end

    def with_most_recent_names
      most_recent_name_entries =
      Name.select('id')
      .where(is_most_recent: true)

      includes(names: :translations)
      .where(names: { id: most_recent_name_entries })
    end
  end
end
