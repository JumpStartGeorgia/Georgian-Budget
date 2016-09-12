require 'rails_helper'
require Rails.root.join('spec', 'models', 'concerns', 'nameable_spec')

RSpec.describe Program, type: :model do
  it_behaves_like 'nameable'

  let(:name_text1) { 'Name #1' }
  let(:name_text2) { 'Name #2' }
  let(:name_text3) { 'Name #3' }
  let(:name_text4) { 'Name #4' }

  let(:program1) { FactoryGirl.create(:program) }
  let(:program2) { FactoryGirl.create(:program) }

  let(:name1) do
    FactoryGirl.create(
      :name,
      text: name_text1,
      start_date: Date.new(2015, 1, 1),
      nameable: program1
    )
  end

  let(:name2) do
    FactoryGirl.create(
      :name,
      text: name_text2,
      start_date: Date.new(2014, 1, 1),
      nameable: program2
    )
  end

  describe '.find_by_name' do
    it 'returns programs with name' do
      FactoryGirl.create(
        :name,
        text: name_text2,
        start_date: name1.start_date + 5,
        nameable: program1
      )

      program2 = FactoryGirl.create(:program)
      FactoryGirl.create(:name, text: name_text2, nameable: program2)

      program3 = FactoryGirl.create(:program)
      FactoryGirl.create(:name, text: name_text1, nameable: program3)

      expect(Program.find_by_name(name_text1)).to eq([program1, program3])
    end
  end

  describe '.with_most_recent_names' do
    it 'gets most recent names' do
      # add less recent name to program1
      name3 = FactoryGirl.create(
        :name,
        text: name_text2,
        start_date: name1.start_date - 5,
        nameable: program1
      )

      # add more recent name to program2
      name4 = FactoryGirl.create(
        :name,
        text: name_text4,
        start_date: name2.start_date + 5,
        nameable: program2
      )

      programs_with_names = Program.with_most_recent_names

      expect(programs_with_names.find(program1.id).name).to eq(name1.text)
      expect(programs_with_names.find(program2.id).name).to eq(name4.text)
    end

    it 'issues just 3 queries (with subsequent nameable.name calls)' do
      program1.save!
      name1.save!
      program2.save!
      name2.save!

      expect do
        programs_with_names = Program.all.with_most_recent_names
        programs_with_names[0].name
        programs_with_names[1].name
      end.to query_limit_eq(3)
    end

  end
end
