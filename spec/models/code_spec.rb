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

  context '#parent_code' do
    context 'when code number is 05 00' do
      context 'and there is one 05 code' do
        it 'returns nil' do
          saved_code1.update_attributes(number: '05')
          new_code.number = '05 00'

          expect(new_code.parent_code).to eq(nil)
        end
      end
    end

    context 'when number is 01 05' do
      context 'and there are no 01 00 codes' do
        it 'returns nil' do
          new_code.number = '01 05'

          expect(new_code.parent_code).to eq(nil)
        end
      end

      context 'and there is one 01 00 code with earlier start date' do
        it 'returns that 01 00 code' do
          saved_code1.update_attributes(
            number: '01 00',
            start_date: new_code.start_date - 1)

          new_code.number = '01 05'

          expect(new_code.parent_code).to eq(saved_code1)
        end
      end

      context 'and there is one 01 00 code with same start date' do
        it 'returns that 01 00 code' do
          saved_code1.update_attributes(
            number: '01 00',
            start_date: new_code.start_date)

          new_code.number = '01 05'

          expect(new_code.parent_code).to eq(saved_code1)
        end
      end

      context 'and there is one 01 00 code with a later start date' do
        it 'returns nil' do
          saved_code1.update_attributes(
            number: '01 00',
            start_date: new_code.start_date + 1)

          new_code.number = '01 05'

          expect(new_code.parent_code).to eq(nil)
        end
      end

      context 'and there are three 01 00 codes' do
        context 'and start dates are before, the same, and after' do
          it 'returns the code with the same start date' do
            saved_code1.update_attributes(
              number: '01 00',
              start_date: new_code.start_date - 1)

            saved_code2.update_attributes(
              number: '01 00',
              start_date: new_code.start_date)

            saved_code3.update_attributes(
              number: '01 00',
              start_date: new_code.start_date + 1)

            new_code.number = '01 05'

            expect(new_code.parent_code).to eq(saved_code2)
          end
        end
      end
    end

    context 'when number is 01 243 55' do
      context 'and there are no 01 243 codes' do
        it 'returns nil' do
          new_code.number = '01 243 55'

          expect(new_code.parent_code).to eq(nil)
        end
      end
    end

    context 'when number is 01 21 23 84' do
      context 'and there are three 01 21 23 codes' do
        context 'and start dates are before, same, and after' do
          it 'returns code with same start date' do
            saved_code1.update_attributes(
              number: '01 21 23',
              start_date: new_code.start_date - 1)

            saved_code2.update_attributes(
              number: '01 21 23',
              start_date: new_code.start_date)

            saved_code3.update_attributes(
              number: '01 21 23',
              start_date: new_code.start_date + 1)

            new_code.number = '01 21 23 84'

            expect(new_code.parent_code).to eq(saved_code2)
          end
        end
      end
    end
  end
end
