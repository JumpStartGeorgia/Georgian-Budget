class Name < ApplicationRecord
  belongs_to :nameable, polymorphic: true

  translates :text, fallbacks_for_empty_translations: true
  globalize_accessors locales: [:en, :ka], attributes: [:text]

  validates :start_date, presence: true
  validates :nameable, presence: true
  validate :validate_text_not_empty_string

  before_save :clean_texts

  def self.texts_represent_same_budget_item?(text1, text2)
    unless (text1.is_a? String) && (text2.is_a? String)
      raise 'Texts must be strings'
    end

    aggressively_clean_text(text1) == aggressively_clean_text(text2)
  end

  private

  def clean_texts
    self.text_en = Name.clean_text(text_en)
    self.text_ka = Name.clean_text(text_ka)
  end

  def self.aggressively_clean_text(text)
    clean_text(
      text
      .gsub('—', ' ')
      .gsub('-', ' ')
      .gsub('–', ' ') # this is a different kind of dash
      .gsub(',', ' ')
      .gsub('(', ' ')
      .gsub(')', ' ')
      .gsub('/', ' ')
      .gsub('\\', ' ')
    )
  end

  def self.clean_text(text)
    return nil if text.nil?

    text
    .gsub(/\s+/, ' ')
    .strip
  end

  def validate_text_not_empty_string
    errors.add(:text_ka, 'cannot be an empty string') if text_ka == ''
    errors.add(:text_en, 'cannot be an empty string') if text_en == ''
  end
end
