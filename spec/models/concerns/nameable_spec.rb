require 'rails_helper'

RSpec.shared_examples_for 'nameable' do
  let(:described_class_sym) { described_class.to_s.underscore.to_sym }

  let(:name_text1) { 'Name #1' }
  let(:name_text2) { 'Name #2' }
  let(:name_text3) { 'Name #3' }
  let(:name_text4) { 'Name #4' }

  let(:nameable1) { FactoryGirl.create(described_class_sym) }
  let(:nameable2) { FactoryGirl.create(described_class_sym) }

  let(:name1) do
    FactoryGirl.create(
      :name,
      text: name_text1,
      start_date: Date.new(2015, 1, 1),
      nameable: nameable1
    )
  end

  let(:name2) do
    FactoryGirl.create(
      :name,
      text: name_text2,
      start_date: Date.new(2014, 1, 1),
      nameable: nameable2
    )
  end

  let(:name1b) do
    FactoryGirl.create(
      :name,
      text: name_text3,
      start_date: name1.start_date + 1,
      nameable: nameable1
    )
  end

  let(:name2b) do
    FactoryGirl.create(
      :name,
      text: name_text4,
      start_date: name2.start_date + 1,
      nameable: nameable2
    )
  end

  describe '#name' do
    it 'returns most recent name' do
      FactoryGirl.create(
        :name,
        text: name_text1,
        start_date: Date.new(2015, 5, 2),
        end_date: Date.new(2015, 12, 31),
        nameable: nameable1
      )

      FactoryGirl.create(
        :name,
        text: name_text2,
        start_date: Date.new(2015, 1, 1),
        end_date: Date.new(2015, 5, 1),
        nameable: nameable1
      )

      expect(nameable1.name).to eq(name_text1)
    end
  end

  describe '.find_by_name' do
    it 'returns nameables with name' do
      FactoryGirl.create(
        :name,
        text: name_text2,
        start_date: name1.start_date + 5,
        nameable: nameable1
      )

      nameable2 = FactoryGirl.create(described_class_sym)
      FactoryGirl.create(:name, text: name_text2, nameable: nameable2)

      nameable3 = FactoryGirl.create(described_class_sym)
      FactoryGirl.create(:name, text: name_text1, nameable: nameable3)

      expect(described_class.find_by_name(name_text1)).to eq([nameable1, nameable3])
    end
  end

  describe '.with_most_recent_names' do
    it 'gets most recent names' do
      # add less recent name to nameable1
      name3 = FactoryGirl.create(
        :name,
        text: name_text2,
        start_date: name1.start_date - 5,
        nameable: nameable1
      )

      # add more recent name to nameable2
      name4 = FactoryGirl.create(
        :name,
        text: name_text4,
        start_date: name2.start_date + 5,
        nameable: nameable2
      )

      nameables_with_names = described_class.with_most_recent_names

      expect(nameables_with_names.find(nameable1.id).name).to eq(name1.text)
      expect(nameables_with_names.find(nameable2.id).name).to eq(name4.text)
    end

    it 'issues just 3 queries (with subsequent nameable.name calls)' do
      nameable1.save!
      name1.save!
      nameable2.save!
      name2.save!

      expect do
        nameables_with_names = described_class.all.with_most_recent_names
        nameables_with_names[0].name
        nameables_with_names[1].name
      end.to query_limit_eq(3)
    end

  end
end
