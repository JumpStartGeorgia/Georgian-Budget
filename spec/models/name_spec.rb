require 'rails_helper'

RSpec.describe Name, type: :model do
  let(:name1) do
    FactoryGirl.create(
      :name,
      nameable: FactoryGirl.create(:program)
    )
  end

  let(:name1b) do
    FactoryGirl.create(
      :name,
      start_date: name1.start_date + 1,
      nameable: name1.nameable
    )
  end

  describe '#nameable' do
    it 'is required' do
      name1.nameable = nil

      expect(name1).to have(1).error_on(:nameable)
    end
  end

  describe '#start_date' do
    it 'is required' do
      name1.start_date = nil
      name1.valid?

      expect(name1).to have(1).errors_on(:start_date)
    end
  end

  describe '#text=' do
    it 'cleans text of extra spaces' do
      name = FactoryGirl.create(:name, text: 'my  name')
      expect(name.text).to eq('my name')
    end

    it 'strips text of surrounding space' do
      name = FactoryGirl.create(:name, text: ' my name ')
      expect(name.text).to eq('my name')
    end

    it 'converts new line characters to space characters' do
      name = FactoryGirl.create(:name, text: "my\nname")
      expect(name.text).to eq('my name')
    end
  end

  describe '#text_en=' do
    it 'cleans text of extra spaces' do
      name = FactoryGirl.create(:name, text_en: 'my  name')
      expect(name.text_en).to eq('my name')
    end

    it 'strips text of surrounding space' do
      name = FactoryGirl.create(:name, text_en: ' my name ')
      expect(name.text_en).to eq('my name')
    end

    it 'converts new line characters to space characters' do
      name = FactoryGirl.create(:name, text_en: "my\nname")
      expect(name.text_en).to eq('my name')
    end
  end

  describe '#text_ka=' do
    it 'cleans text of extra spaces' do
      name = FactoryGirl.create(:name, text_ka: 'my  name')
      expect(name.text_ka).to eq('my name')
    end

    it 'strips text of surrounding space' do
      name = FactoryGirl.create(:name, text_ka: ' my name ')
      expect(name.text_ka).to eq('my name')
    end

    it 'converts new line characters to space characters' do
      name = FactoryGirl.create(:name, text_ka: "my\nname")
      expect(name.text_ka).to eq('my name')
    end
  end

  describe '#text' do
    it 'cannot be empty string' do
      I18n.locale = 'ka'
      name = FactoryGirl.build(:name, text: '')

      expect(name.valid?).to eq(false)
      expect(name).to have(1).errors_on(:text_ka)
    end
  end

  describe '#text_en' do
    it 'cannot be empty string' do
      name = FactoryGirl.build(:name, text_en: '')

      expect(name.valid?).to eq(false)
      expect(name).to have(1).errors_on(:text_en)
    end
  end

  describe '#text_ka' do
    it 'cannot be empty string' do
      name = FactoryGirl.build(:name, text_ka: '')

      expect(name.valid?).to eq(false)
      expect(name).to have(1).errors_on(:text_ka)
    end
  end

  describe '.texts_represent_same_budget_item?' do
    it 'returns false if text is different' do
      text1 = 'Name1'
      text2 = 'Name2'

      expect(Name.texts_represent_same_budget_item?(text1, text2)).to eq(false)
    end

    it 'returns true if difference is short dash vs. space' do
      text1 = 'Name-1'
      text2 = 'Name 1'

      expect(Name.texts_represent_same_budget_item?(text1, text2)).to eq(true)
    end

    it 'returns true if difference is long dash vs. space' do
      text1 = 'Name—1'
      text2 = 'Name 1'

      expect(Name.texts_represent_same_budget_item?(text1, text2)).to eq(true)
    end

    it 'returns true if difference is comma vs. space' do
      text1 = 'Name, 1'
      text2 = 'Name 1'

      expect(Name.texts_represent_same_budget_item?(text1, text2)).to eq(true)
    end

    it 'returns true if difference is parentheses vs. space' do
      text1 = 'Name (1)'
      text2 = 'Name 1'

      expect(Name.texts_represent_same_budget_item?(text1, text2)).to eq(true)
    end

    it 'returns true if difference is forward slash vs. space' do
      text1 = 'Name/1'
      text2 = 'Name 1'

      expect(Name.texts_represent_same_budget_item?(text1, text2)).to eq(true)
    end

    it 'returns true if difference is backward slash vs. space' do
      text1 = 'Name\1'
      text2 = 'Name 1'

      expect(Name.texts_represent_same_budget_item?(text1, text2)).to eq(true)
    end

    it 'returns true if difference is small dash vs. strange long dash' do
      text1 = 'Name - 1'
      text2 = 'Name – 1'

      expect(Name.texts_represent_same_budget_item?(text1, text2)).to eq(true)
    end
  end
end
