require 'rails_helper'

RSpec.shared_examples_for 'Codeable' do
  let(:described_class_sym) { described_class.to_s.underscore.to_sym }

  let(:codeable1) { FactoryGirl.create(described_class_sym) }

  let(:new_code_attr) { FactoryGirl.attributes_for(:code) }
  let(:already_saved_code_attr1) { FactoryGirl.attributes_for(:code) }
  let(:already_saved_code_attr2) { FactoryGirl.attributes_for(:code) }

  describe '#codes' do
    it 'gets codes in chronological order according to start date' do
      codeable1.add_code(already_saved_code_attr1)
      new_code_attr[:start_date] = already_saved_code_attr1[:start_date] - 1

      new_code = codeable1.add_code(new_code_attr, return_code: true)
      codeable1.reload

      expect(codeable1.codes.first.id).to eq(new_code.id)
    end
  end

  describe '#code_on_date' do
    let(:jan_1_2012) { Date.new(2012, 1, 1) }

    context 'when codeable has no codes' do
      it 'returns nil' do
        expect(codeable1.code_on_date(jan_1_2012)).to eq(nil)
      end
    end

    context 'when codeable has one code with start date before arg date' do
      it 'returns that code' do
        new_code_attr[:start_date] = jan_1_2012 - 1
        code = codeable1.add_code(new_code_attr, return_code: true)

        expect(
          codeable1.code_on_date(jan_1_2012)
        ).to eq(code)
      end
    end

    context 'when codeable has one code with start date on arg date' do
      it 'returns that code' do
        new_code_attr[:start_date] = jan_1_2012
        code = codeable1.add_code(new_code_attr, return_code: true)

        expect(
          codeable1.code_on_date(jan_1_2012)
        ).to eq(code)
      end
    end

    context 'when codeable has one code with start date after arg date' do
      it 'returns nil' do
        new_code_attr[:start_date] = jan_1_2012 + 1
        codeable1.add_code(new_code_attr)

        expect(
          codeable1.code_on_date(jan_1_2012)
        ).to eq(nil)
      end
    end

    context 'when codeable has three codes' do
      context 'with start dates before, on, and after arg date' do
        it 'returns code with start date on arg date' do
          already_saved_code_attr1[:start_date] = jan_1_2012 - 1
          codeable1.add_code(already_saved_code_attr1)

          already_saved_code_attr2[:start_date] = jan_1_2012
          jan_1_2012_code = codeable1.add_code(
            already_saved_code_attr2,
            return_code: true)

          new_code_attr[:start_date] = jan_1_2012 + 1
          codeable1.add_code(new_code_attr)

          expect(
            codeable1.code_on_date(jan_1_2012)
          ).to eq(jan_1_2012_code)
        end
      end
    end
  end

  describe '#add_code' do
    context 'when code is invalid' do
      it 'raises error' do
        new_code_attr[:start_date] = nil

        expect do
          codeable1.add_code(new_code_attr)
        end.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context 'when code start date is before codeable start date' do
      it 'updates codeable start date to code start date' do
        codeable1.start_date = Date.new(2012, 1, 2)
        codeable1.save

        new_code_attr[:start_date] = Date.new(2012, 1, 1)

        codeable1.add_code(new_code_attr)

        codeable1.reload
        expect(codeable1.start_date).to eq(Date.new(2012, 1, 1))
      end
    end

    context 'when codeable has no other codes' do
      it 'causes codeable to have 1 code' do
        codeable1.add_code(new_code_attr)
        codeable1.reload

        expect(codeable1.codes.length).to eq(1)
      end

      it 'saves code number as codeable.code' do
        codeable1.add_code(new_code_attr)
        codeable1.reload

        expect(codeable1.code).to eq(new_code_attr[:number])
      end
    end

    context 'when codeable has other code with the same number' do
      before :example do
        codeable1.add_code(already_saved_code_attr1)
        new_code_attr[:number] = already_saved_code_attr1[:number]
      end

      context 'and new code is more recent' do
        before :example do
          new_code_attr[:start_date] = already_saved_code_attr1[:start_date] + 1
        end

        it 'causes codeable to have 1 code' do
          codeable1.add_code(new_code_attr)
          codeable1.reload

          expect(codeable1.codes.length).to eq(1)
        end

        it "causes codeable to have 1 code with already saved code's start date" do
          codeable1.add_code(new_code_attr)
          codeable1.reload

          expect(codeable1.codes[0].start_date)
          .to eq(already_saved_code_attr1[:start_date])
        end
      end

      context 'and new code is less recent' do
        before :example do
          new_code_attr[:start_date] = already_saved_code_attr1[:start_date] - 1
        end

        it 'causes codeable to have 1 code' do
          codeable1.add_code(new_code_attr)
          codeable1.reload

          expect(codeable1.codes.length).to eq(1)
        end

        it "causes codeable to have 1 code with new code's start date" do
          codeable1.add_code(new_code_attr)
          codeable1.reload

          expect(codeable1.codes[0].start_date)
          .to eq(new_code_attr[:start_date])
        end
      end
    end

    context 'when codeable has already saved code with different number' do
      before :example do
        codeable1.add_code(already_saved_code_attr1)
      end

      context 'and new code is more recent' do
        before :example do
          new_code_attr[:start_date] = already_saved_code_attr1[:start_date] + 1
        end

        it 'causes codeable to have 2 codes' do
          codeable1.add_code(new_code_attr)
          codeable1.reload

          expect(codeable1.codes.length).to eq(2)
        end

        it 'saves the new code number as codeable.code' do
          codeable1.add_code(new_code_attr)
          codeable1.reload

          expect(codeable1.code).to eq(new_code_attr[:number])
        end
      end

      context 'and new code is less recent' do
        before :example do
          new_code_attr[:start_date] = already_saved_code_attr1[:start_date] - 1
        end

        it 'causes codeable to have 2 codes' do
          codeable1.add_code(new_code_attr)
          codeable1.reload

          expect(codeable1.codes.length).to eq(2)
        end

        it 'keeps the other code number as codeable.code' do
          codeable1.add_code(new_code_attr)
          codeable1.reload

          expect(codeable1.code).to eq(already_saved_code_attr1[:number])
        end
      end
    end

    context 'when codeable has two older codes' do
      before :example do
        already_saved_code_attr2[:start_date] = already_saved_code_attr1[:start_date] + 1
        new_code_attr[:start_date] = already_saved_code_attr2[:start_date] + 1

        codeable1
        .add_code(already_saved_code_attr1)
        .add_code(already_saved_code_attr2)
      end

      context 'and oldest code has same number' do
        before :example do
          new_code_attr[:number] = already_saved_code_attr1[:start_date]
        end

        it 'causes codeable to have 3 codes' do
          codeable1.add_code(new_code_attr)
          codeable1.reload

          expect(codeable1.codes.length).to eq(3)
        end
      end
    end
  end

  describe '#take_code' do
    context 'when codeable has no codes' do
      it 'increases codeable code amount to 1' do
        codeable1.take_code(FactoryGirl.create(:code))

        expect(codeable1.codes.count).to eq(1)
      end

      it "takes code away from old code's codeable" do
        code = FactoryGirl.create(:code)
        old_codeable = code.codeable

        codeable1.take_code(code)

        expect(old_codeable.codes.count).to eq(0)
      end
    end
  end
end
