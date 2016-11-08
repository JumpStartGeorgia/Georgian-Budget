class BudgetItemTranslations
  def initialize(path)
    @path = path
  end

  def save
    I18n.locale = 'en'
    names = Name.includes(:translations)

    require('csv')
    CSV.read(path).each_with_index do |row, index|
      next if index === 0

      georgian_name = row[1]
      english_name = row[3]

      next if georgian_name.blank?
      next if english_name.blank?

      names_to_translate = names.select do |name|
        (name.text_ka == georgian_name) ||
        (name.text_ka == georgian_name.gsub('-', '–'))
      end

      next unless names_to_translate.present?

      names_to_translate.each do |name_to_translate|
        name_to_translate.text = english_name
        name_to_translate.save
      end
    end
  end

  attr_reader :path
end
