require 'rails_helper'

RSpec.shared_examples_for 'nameable' do
  let(:name_text1) { 'Name #1' }
  let(:name_text2) { 'Name #2' }
  let(:name_text3) { 'Name #3' }
  let(:name_text4) { 'Name #4' }

  let(:program1) do
    FactoryGirl.create(described_class.to_s.underscore.to_sym)
  end
  let(:program2) { FactoryGirl.create(described_class.to_s.underscore.to_sym) }

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

  describe '#name' do
    it 'returns most recent name' do
      FactoryGirl.create(
        :name,
        text: name_text1,
        start_date: Date.new(2015, 5, 2),
        end_date: Date.new(2015, 12, 31),
        nameable: program1
      )

      FactoryGirl.create(
        :name,
        text: name_text2,
        start_date: Date.new(2015, 1, 1),
        end_date: Date.new(2015, 5, 1),
        nameable: program1
      )

      expect(program1.name).to eq(name_text1)
    end
  end
end
