require 'rails_helper'

RSpec.describe PriorityConnector do
  let!(:priority) { create(:priority) }
  let!(:agency) { create(:spending_agency) }
  let!(:programA) do
    create(:program,
      spending_agency: agency)
  end

  let!(:programAA) do
    create(:program,
      parent_program: programA,
      spending_agency: agency)
  end

  let!(:programAAA) do
    create(:program,
      parent_program: programAA,
      spending_agency: agency)
  end

  let!(:programAAAA) do
    create(:program,
      parent_program: programAAA,
      spending_agency: agency)
  end

  let!(:programAAAAA) do
    create(:program,
      parent_program: programAAAA,
      spending_agency: agency)
  end

  let!(:programAAAB) do
    create(:program,
      parent_program: programAAA,
      spending_agency: agency)
  end

  let!(:programAAB) do
    create(:program,
      parent_program: programAA,
      spending_agency: agency)
  end

  let(:connected_items) do
    PriorityConnection.all.map(&:priority_connectable)
  end

  let(:directly_connected_items) do
    PriorityConnection.direct.map(&:priority_connectable)
  end

  let(:indirectly_connected_items) do
    PriorityConnection.indirect.map(&:priority_connectable)
  end

  describe '#connect' do
    context 'when connection is direct' do
      it 'only directly connects the item' do
        PriorityConnector.new(
          programAAA,
          attributes_for(:priority_connection, direct: true, priority_id: priority.id)
        ).connect

        expect(directly_connected_items).to contain_exactly(programAAA)
      end

      it 'indirectly connects programs of agency' do
        PriorityConnector.new(
          agency,
          attributes_for(:priority_connection, direct: true, priority_id: priority.id)
        ).connect

        expect(indirectly_connected_items).to contain_exactly(
          programA,
          programAA,
          programAAA,
          programAAAA,
          programAAAAA,
          programAAAB,
          programAAB
        )
      end

      it 'indirectly connects descendant programs and ancestors of program' do
        PriorityConnector.new(
          programAAA,
          attributes_for(:priority_connection, direct: true, priority_id: priority.id)
        ).connect

        expect(indirectly_connected_items).to contain_exactly(
          agency,
          programA,
          programAA,
          programAAAA,
          programAAAAA,
          programAAAB
        )
      end

      it 'only creates one indirect connection even when multiple related items are directly connected' do
        PriorityConnector.new(
          programAAA,
          attributes_for(:priority_connection,
            time_period_obj: Year.new(2012),
            direct: true,
            priority_id: priority.id)
        ).connect

        PriorityConnector.new(
          programAAB,
          attributes_for(:priority_connection,
            time_period_obj: Year.new(2012),
            direct: true,
            priority_id: priority.id)
        ).connect

        expect(PriorityConnection.where(priority_connectable: programAA).count).to eq(1)
        expect(PriorityConnection.where(priority_connectable: agency).count).to eq(1)
      end
    end

    context 'when connection is indirect' do
      it 'only connects the item' do
        PriorityConnector.new(
          programAAA,
          attributes_with_foreign_keys(:priority_connection, direct: false)
        ).connect

        expect(connected_items).to contain_exactly(programAAA)
      end
    end
  end
end
