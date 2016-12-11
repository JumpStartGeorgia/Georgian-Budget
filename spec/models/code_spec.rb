require 'rails_helper'

RSpec.describe Code, type: :model do
  let(:new_code) { FactoryGirl.build(:code) }

  let(:saved_code1) { FactoryGirl.create(:code) }
  let(:saved_code2) { FactoryGirl.create(:code) }
  let(:saved_code3) { FactoryGirl.create(:code) }

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
  
  describe '#generation' do
    context 'when code has two parts and ends with 00' do
      it 'is 1' do
        code = FactoryGirl.create(:code, number: '01 00')
        expect(code.generation).to eq(1)
      end
    end

    context 'when code has two parts and ends with 01' do
      it 'is 2' do
        code = FactoryGirl.create(:code, number: '01 01')
        expect(code.generation).to eq(2)
      end
    end

    context 'when code has three parts' do
      it 'is 3' do
        code = FactoryGirl.create(:code, number: '011 01 04')
        expect(code.generation).to eq(3)
      end
    end

    context 'when code has five parts' do
      it 'is 5' do
        code = FactoryGirl.create(:code, number: '0122 01 0143 08 4343434')
        expect(code.generation).to eq(5)
      end
    end
  end
end
