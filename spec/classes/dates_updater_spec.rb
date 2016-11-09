require 'rails_helper'

RSpec.describe DatesUpdater do
  let(:target_item) { FactoryGirl.create(:program) }
  let(:updater_item) { FactoryGirl.create(:spent_finance) }

  describe '#update' do
    context 'when both items respond to start date' do
      context "and target item's start date is before updater item" do
        it "does not change target item's start date" do
          target_item.update_column(:start_date, Date.new(2012, 1, 1))
          updater_item.update_column(:start_date, Date.new(2012, 1, 2))

          DatesUpdater.new(target_item, updater_item).update

          target_item.reload
          expect(target_item.start_date).to eq(Date.new(2012, 1, 1))
        end
      end

      context "and updater item's start date is nil" do
        it "does not change target item's start date" do
          target_item.update_column(:start_date, Date.new(2012, 1, 1))
          updater_item.update_column(:start_date, nil)

          DatesUpdater.new(target_item, updater_item).update

          target_item.reload
          expect(target_item.start_date).to eq(Date.new(2012, 1, 1))
        end
      end

      context "and target item's start date is after updater item" do
        it "changes target item's start date to updater item's start date" do
          target_item.update_column(:start_date, Date.new(2012, 1, 2))
          updater_item.update_column(:start_date, Date.new(2012, 1, 1))

          DatesUpdater.new(target_item, updater_item).update

          target_item.reload
          expect(target_item.start_date).to eq(Date.new(2012, 1, 1))
        end
      end

      context "and target item's start date is nil" do
        it "changes target item's start date to updater item's start date" do
          target_item.update_column(:start_date, nil)
          updater_item.update_column(:start_date, Date.new(2012, 1, 1))

          DatesUpdater.new(target_item, updater_item).update

          target_item.reload
          expect(target_item.start_date).to eq(Date.new(2012, 1, 1))
        end
      end
    end

    context 'when both items respond to end date' do
      context "and target item's end date is after updater item" do
        it "does not change target item's end date" do
          target_item.update_column(:end_date, Date.new(2012, 1, 2))
          updater_item.update_column(:end_date, Date.new(2012, 1, 1))

          DatesUpdater.new(target_item, updater_item).update

          target_item.reload
          expect(target_item.end_date).to eq(Date.new(2012, 1, 2))
        end
      end

      context "and updater item's end date is nil" do
        it "does not change target item's end date" do
          target_item.update_column(:end_date, Date.new(2012, 1, 2))
          updater_item.update_column(:end_date, nil)

          DatesUpdater.new(target_item, updater_item).update

          target_item.reload
          expect(target_item.end_date).to eq(Date.new(2012, 1, 2))
        end
      end

      context "and target item's end date is before updater item" do
        it "changes target item's end date to updater item's end date" do
          target_item.update_column(:end_date, Date.new(2012, 1, 1))
          updater_item.update_column(:end_date, Date.new(2012, 1, 2))

          DatesUpdater.new(target_item, updater_item).update

          target_item.reload
          expect(target_item.end_date).to eq(Date.new(2012, 1, 2))
        end
      end

      context "and target item's end date is nil" do
        it "changes target item's end date to updater item's end date" do
          target_item.update_column(:end_date, nil)
          updater_item.update_column(:end_date, Date.new(2012, 1, 2))

          DatesUpdater.new(target_item, updater_item).update

          target_item.reload
          expect(target_item.end_date).to eq(Date.new(2012, 1, 2))
        end
      end
    end
  end
end
