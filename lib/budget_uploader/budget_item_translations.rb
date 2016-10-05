class BudgetItemTranslations
  def initialize(path)
    @path = path
  end

  def save
    names = Name.includes(:translations)

    require('csv')
    CSV.read(path).each_with_index do |row, index|
      next if index === 0

      georgian_name = row[1]
      english_name = row[3]

      name_to_translate = names.find do |name|
        name.text_ka == georgian_name
      end

      next unless name_to_translate.present?

      name_to_translate.text_en = english_name
      name_to_translate.save
    end
  end

  attr_reader :path
end
