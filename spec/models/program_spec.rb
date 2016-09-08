require 'rails_helper'

RSpec.describe 'Program', type: :model do
  let(:name_text1) { 'Name #1' }
  let(:name_text2) { 'Name #2' }

  describe '#name' do
    it 'returns most recent name' do
      program = FactoryGirl.create(:program)
      old_name = 'Old Program'
      new_name = 'New Program'

      FactoryGirl.create(
        :name,
        text: old_name,
        start_date: Date.new(2015, 1, 1),
        end_date: Date.new(2015, 5, 1),
        nameable: program
      )

      FactoryGirl.create(
        :name,
        text: new_name,
        start_date: Date.new(2015, 5, 2),
        end_date: Date.new(2015, 12, 31),
        nameable: program
      )

      expect(program.name).to eq(new_name)
    end
  end

  describe '.find_by_name' do
    it 'returns programs with name' do
      program1 = FactoryGirl.create(:program)
      name1 = FactoryGirl.create(:name, text: name_text1, nameable: program1)
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
end
