require 'rails_helper'
require Rails.root.join('lib', 'budget_uploader', 'budget_files').to_s

RSpec.describe 'BudgetFiles' do
  describe '#upload' do
    before :example do
      I18n.locale = 'ka'
    end

    context 'with priorities list and priority associations list' do
      before :context do
        @january_2012 = Month.for_date(Date.new(2012, 1, 1))
        @quarter1_2012 = Quarter.for_date(Date.new(2012, 1, 1))
        # Setup parliament agency
        @parliament = SpendingAgency.create
        .add_code(number: '01 00', start_date: Date.new(2012, 1, 1))
        .add_name(
          text_ka: 'საქართველოს პარლამენტი და მასთან არსებული ორგანიზაციები',
          start_date: Date.new(2012, 1, 1))
        .save_perma_id


        # Setup audit regulation program
        @audit_regulation_program = Program.create
        .add_code(number: '01 02', start_date: Date.new(2012, 1, 1))
        .add_name(
          text_ka: 'აუდიტორული საქმიანობის სახელმწიფო რეგულირება',
          start_date: Date.new(2012, 1, 1))
        .save_perma_id

        # Setup library program
        @library_program = Program.create
        .add_code(number: '01 02', start_date: Date.new(2013, 1, 1))
        .add_name(
          text_ka: 'საბიბლიოთეკო საქმიანობა',
          start_date: Date.new(2013, 1, 1))
        .save_perma_id
        .add_spent_finance(
          time_period_obj: @january_2012,
          amount: 30)
        .add_planned_finance(
          time_period_obj: @quarter1_2012,
          announce_date: @quarter1_2012.start_date,
          amount: 300)

        @financier_qualifications_program = Program.create
        .add_code(number: '23 05', start_date: Date.new(2012, 1, 1))
        .add_name(
          text_ka: 'საფინანსო სექტორში დასაქმებულთა კვალიფიკაციის ამაღლება',
          start_date: Date.new(2012, 1, 1))
        .save_perma_id
        .add_spent_finance(
          time_period_obj: @january_2012,
          amount: 70)
        .add_planned_finance(
          time_period_obj: @quarter1_2012,
          announce_date: @quarter1_2012.start_date,
          amount: 200)

        # Exercise
        BudgetFiles.new(
          priorities_list: BudgetFiles.priorities_list,
          priority_associations_list: BudgetFiles.priority_associations_list
        ).upload
      end

      after :context do
        Deleter.delete_all
      end

      let(:uncategorized_priority) do
        Priority.with_name_in_history('უკატეგორიო')[0]
      end

      let(:economic_stability_priority) do
        Priority.with_name_in_history(
          'მაკროეკონომიკური სტაბილურობა და საინვესტიციო გარემოს გაუმჯობესება'
        )[0]
      end

      let(:education_priority) do
        Priority.with_name_in_history(
          'განათლება, მეცნიერება და პროფესიული მომზადება'
        )[0]
      end

      it 'creates uncategorized priority' do
        expect(uncategorized_priority).to_not eq(nil)

        expect(uncategorized_priority.recent_name_object.start_date)
        .to eq(Date.new(2012, 1, 1))
      end

      it 'creates perma_id for uncategorized priority' do
        expect(uncategorized_priority.perma_id).to_not eq(nil)
      end

      it 'assigns parliament to uncategorized priority' do
        @parliament.reload
        expect(@parliament.priority).to eq(uncategorized_priority)
      end

      it 'creates economic stability priority' do
        expect(economic_stability_priority).to_not eq(nil)

        expect(economic_stability_priority.recent_name_object.start_date)
        .to eq(Date.new(2012, 1, 1))
      end

      it 'creates perma_id for economic stability priority' do
        expect(economic_stability_priority.perma_id).to_not eq(nil)
      end

      it 'assigns audit regulation program to economic stability priority' do
        @audit_regulation_program.reload
        expect(@audit_regulation_program.priority).to eq(economic_stability_priority)
      end

      it 'creates education priority' do
        expect(education_priority).to_not eq(nil)

        expect(education_priority.recent_name_object.start_date)
        .to eq(Date.new(2012, 1, 1))
      end

      it 'creates perma_id for education priority' do
        expect(education_priority.perma_id).to_not eq(nil)
      end

      it "sets education priority's monthly spent finances" do
        monthly_spent_finances = education_priority.spent_finances.monthly

        expect(monthly_spent_finances.length).to eq(1)
        expect(monthly_spent_finances[0].amount).to eq(100)
        expect(monthly_spent_finances[0].time_period_obj).to eq(@january_2012)
      end

      it "sets education priority's quarterly spent finances" do
        quarterly_spent_finances = education_priority.spent_finances.quarterly

        expect(quarterly_spent_finances.length).to eq(1)
        expect(quarterly_spent_finances[0].amount).to eq(100)
        expect(quarterly_spent_finances[0].time_period_obj).to eq(
          Quarter.for_date(Date.new(2012, 1, 1)))
      end

      it "sets education priority's planned finances" do
        planned_finances = education_priority.planned_finances

        expect(planned_finances[0].amount).to eq(500)
        expect(planned_finances[0].time_period_obj).to eq(@quarter1_2012)
      end

      it 'sets priority of library program' do
        @library_program.reload
        expect(@library_program.priority).to eq(education_priority)
      end

      it 'assigns financier_qualifications_program to education priority' do
        @financier_qualifications_program.reload
        expect(@financier_qualifications_program.priority).to eq(education_priority)
      end
    end
  end
end
