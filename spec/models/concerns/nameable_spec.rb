require 'rails_helper'

RSpec.shared_examples_for 'Nameable' do
  let(:described_class_sym) { described_class.to_s.underscore.to_sym }

  let(:name_text1) { 'Name #1' }
  let(:name_text2) { 'Name #2' }
  let(:name_text3) { 'Name #3' }
  let(:name_text4) { 'Name #4' }
  let(:name_text5) { 'Name #5' }

  let(:nameable1) { FactoryGirl.create(described_class_sym) }
  let(:nameable2) { FactoryGirl.create(described_class_sym) }
  let(:nameable3) { FactoryGirl.create(described_class_sym) }

  let(:name_start_date) { Date.new(2015, 01, 01) }

  let(:name1) do
    FactoryGirl.create(
      :name,
      text: name_text1,
      start_date: name_start_date,
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

  let(:name3) do
    FactoryGirl.create(
      :name,
      text: name_text5,
      start_date: Date.new(2014, 1, 1),
      nameable: nameable3
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

  let(:name1c) do
    FactoryGirl.create(
      :name,
      start_date: name1b.start_date + 1,
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

  describe '#destroy' do
    it 'destroys associated names' do
      nameable1.save!
      name1.save!
      name1b.save!
      nameable1.reload

      nameable1.destroy

      expect(Name.exists?(name1.id)).to eq(false)
      expect(Name.exists?(name1b.id)).to eq(false)
    end
  end

  describe '#name' do
    it 'returns most recent name text' do
      nameable1.save!
      name1.save!
      name1b.save!
      nameable1.reload

      expect(nameable1.name).to eq(name1b.text)
    end
  end

  describe '#recent_name_object' do
    it 'returns the most recent name object' do
      nameable1.save!
      name1.save!
      name1b.save!
      nameable1.reload

      expect(nameable1.recent_name_object).to eq(name1b)
    end
  end

  describe '.find_by_name' do
    it 'returns nameables with name' do
      name2.save!

      name3.text = name1.text
      name3.save!

      expect(described_class.find_by_name(name_text1)).to match_array([nameable1, nameable3])
    end
  end

  describe '#names' do
    it 'gets names in order of start date' do
      name1
      name1b.start_date = name1.start_date + 1
      name1b.save!

      nameable1.reload
      expect(nameable1.names).to eq([name1, name1b])
    end
  end

  describe '#merge_same_names' do
    context 'when nameable has one name' do
      it 'does not affect name' do
        name1

        nameable1.reload
        nameable1.merge_same_names
        nameable1.reload

        expect(nameable1.names).to eq([name1])
      end
    end

    context 'when nameable has two names' do
      context 'with the same text' do
        before :each do
          name1.start_date = name_start_date
          name1.save!

          name1b.start_date = name1.start_date + 1
          name1b.text = name1.text
          name1b.save!

          nameable1.reload
          nameable1.merge_same_names
          nameable1.reload
        end

        it 'combines names into one name' do
          expect(nameable1.names.length).to eq(1)
        end

        context 'combines names into one name' do
          it 'with earlier start date' do
            merged_name = nameable1.recent_name_object
            expect(merged_name.start_date).to eq(name_start_date)
          end
        end
      end

      context 'with different texts' do
        it 'does not combine names' do
          name1
          name1b

          nameable1.reload
          nameable1.merge_same_names

          nameable1.reload
          expect(nameable1.names).to eq([name1, name1b])
        end
      end
    end

    context 'when nameable has three names' do
      before :each do
        name1
        name1b
        name1c
      end

      context 'and all have the same text' do
        before :each do
          name1b.text = name1.text
          name1b.save!
          name1c.text = name1.text
          name1c.save!
        end

        it 'will merge all names into one' do
          nameable1.reload
          nameable1.merge_same_names
          nameable1.reload
          expect(nameable1.names.length).to eq(1)
        end

        context 'will merge all names into one' do
          it 'with start date equal to earliest name start date' do
            nameable1.reload
            nameable1.merge_same_names
            nameable1.reload
            expect(nameable1.recent_name_object.start_date).to eq(name_start_date)
          end

          it 'with is_most_recent set to true' do
            nameable1.reload
            nameable1.update_names_is_most_recent
            nameable1.merge_same_names
            nameable1.reload
            expect(nameable1.recent_name_object.is_most_recent).to eq(true)
          end
        end
      end

      context 'and the first and third have the same text' do
        it 'will not affect the names' do
          name1c.text = name1.text
          name1c.save!

          nameable1.reload
          nameable1.merge_same_names
          nameable1.reload
          expect(nameable1.names).to match_array([name1, name1b, name1c])
        end
      end
    end

  end

  describe '.with_most_recent_names' do
    it 'loads each nameable with its most recent name object' do
      name1.save!
      name1b.save!
      name1b.nameable.reload
      name1b.run_callbacks(:commit)

      name2.save!
      name2b.save!
      name2b.nameable.reload
      name2b.run_callbacks(:commit)

      nameables_with_names = described_class.with_most_recent_names

      nameable1_with_names = nameables_with_names.find do |nameable|
        nameable.id == nameable1.id
      end

      nameable2_with_names = nameables_with_names.find do |nameable|
        nameable.id == nameable2.id
      end

      expect(nameable1_with_names.recent_name_object).to eq(name1b)
      expect(nameable2_with_names.recent_name_object).to eq(name2b)
    end

    it 'issues just 1 query (with subsequent nameable.name calls)' do
      nameable1.save!
      name1.save!
      nameable2.save!
      name2.save!

      expect do
        nameables_with_names = described_class.all.with_most_recent_names

        nameable1_with_names = nameables_with_names.find do |nameable|
          nameable.id == nameable1.id
        end

        nameable2_with_names = nameables_with_names.find do |nameable|
          nameable.id == nameable2.id
        end

        nameable1_with_names.name
        nameable2_with_names.name
      end.to query_limit_eq(1)
    end

    it 'preloads only one name for each nameable' do
      nameable1.save!
      name1.save!
      name1b.save!

      nameable2.save!
      name2.save!
      name2b.save!

      nameables_with_names = described_class.all.with_most_recent_names

      nameable1_with_names = nameables_with_names.find do |nameable|
        nameable.id = nameable1.id
      end

      nameable2_with_names = nameables_with_names.find do |nameable|
        nameable.id = nameable2.id
      end


      expect(nameable1_with_names.names.length).to eq(1)
      expect(nameable2_with_names.names.length).to eq(1)
    end
  end
end
