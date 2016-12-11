require 'rails_helper'

RSpec.describe ProgramAncestorsUpdater do
  describe '#update' do
    let!(:spending_agency) do
      FactoryGirl.create(:spending_agency)
      .add_code(FactoryGirl.attributes_for(:code, number: '01 00'))
    end

    let!(:parent_program) do
      FactoryGirl.create(:program)
      .add_code(FactoryGirl.attributes_for(:code, number: '01 01'))
    end

    let(:program) do
      FactoryGirl.create(:program)
    end

    before do
      FactoryGirl.create(:code, codeable: program, number: '01 01 01')

      ProgramAncestorsUpdater.new(program).update
    end

    it 'updates parent_program' do
      expect(program.parent_program).to eq(parent_program)
    end

    it 'updates spending_agency' do
      expect(program.spending_agency).to eq(spending_agency)
    end
  end

  describe '#find_spending_agency' do
    let!(:agency0100) do
      FactoryGirl.create(:spending_agency, codes: [
        FactoryGirl.create(:code, number: '01 00')
      ])
    end

    let!(:agency0200) do
      FactoryGirl.create(:spending_agency, codes: [
        FactoryGirl.create(:code, number: '02 00')
      ])
    end

    let(:program) do
      FactoryGirl.create(:program)
    end

    before do
      FactoryGirl.create(:code, codeable: program, number: program_code)
    end

    subject(:found_agency) do
      ProgramAncestorsUpdater.new(program).find_spending_agency
    end

    context 'when program is top-level program' do
      let(:program_code) { '01 01' }

      it { is_expected.to eq(agency0100) }
    end

    context 'when program is subprogram' do
      let(:program_code) { '02 01 01' }

      it { is_expected.to eq(agency0200) }
    end

    context 'when program has two codes' do
      let(:program_code) { '01 01' }

      before do
        FactoryGirl.create(:code,
          codeable: program,
          number: '02 01',
          start_date: program.codes.last.start_date - 1)
      end

      it 'returns the agency matching most recent code' do
        expect(found_agency).to eq(agency0100)
      end
    end
  end

  describe '#find_parent_program' do
    let!(:program0101) do
      FactoryGirl.create(:program)
    end

    let(:program) do
      FactoryGirl.create(:program)
    end

    before do
      FactoryGirl.create(:code, codeable: program0101, number: '01 01')
      FactoryGirl.create(:code, codeable: program, number: program_code)
    end

    subject(:found_parent_program) do
      ProgramAncestorsUpdater.new(program).find_parent_program
    end

    context 'when program is subprogram' do
      let(:program_code) { '01 01 05' }

      it { is_expected.to eq(program0101) }
    end

    context 'when program is top-level program' do
      let(:program_code) { '08 01' }

      it { is_expected.to eq(nil) }
    end

    context 'when program has two codes' do
      let(:program_code) { '01 01 05' }

      let!(:program0201) do
        FactoryGirl.create(:program)
      end

      before do
        FactoryGirl.create(:code, codeable: program0201, number: '02 01')
        FactoryGirl.create(:code,
          codeable: program,
          number: '02 01 01',
          start_date: program.codes.last.start_date + 1)
      end

      it 'returns the parent program matching the most recent code' do
        expect(found_parent_program).to eq(program0201)
      end
    end
  end
end
