module Nameable
  extend ActiveSupport::Concern

  included do
    has_many :names, -> { order 'names.start_date' }, as: :nameable, dependent: :destroy
  end

  # text of most recent name
  def name
    text = recent_name_object.text
    return text if text.present?

    translations = recent_name_object.translations

    return nil unless translations.present?
    return translations[0].text
  end

  def name_ka
    recent_name_object.text_ka
  end

  def name_en
    recent_name_object.text_en
  end

  # most recent name
  def recent_name_object
    names.last
  end

  def update_names
    update_names_is_most_recent
    merge_same_names
  end

  def update_names_is_most_recent
    names.update_all(is_most_recent: false)
    recent_name_object.update_column(:is_most_recent, true)

    return true
  end

  def merge_same_names
    names.to_enum.with_index.reverse_each do |name, index|
      next if index == 0
      previous_name = names[index - 1]

      if name.text == previous_name.text
        previous_name.merge_more_recent_name(name)
      end
    end
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
