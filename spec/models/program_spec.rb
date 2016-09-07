require 'rails_helper'

RSpec.describe 'Program', type: :model do
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
end
