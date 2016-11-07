require 'rails_helper'

RSpec.describe Code, type: :model do
  let(:new_code) { FactoryGirl.build(:code) }

  it 'is valid with valid attributes' do
    expect(new_code.valid?).to eq(true)
  end

  context '#start_date' do
    it 'is required' do
      new_code.start_date = nil

      expect(new_code.valid?).to eq(false)
      expect(new_code).to have(1).errors_on(:start_date)
    end
  end

  context '#number' do
    it 'is required' do
      new_code.number = nil

      expect(new_code.valid?).to eq(false)
      expect(new_code).to have(1).errors_on(:number)
    end
  end

  context '#codeable' do
    it 'is required' do
      new_code.codeable = nil

      expect(new_code.valid?).to eq(false)
      expect(new_code).to have(1).errors_on(:codeable)
    end
  end
end
