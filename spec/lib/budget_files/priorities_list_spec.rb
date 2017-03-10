require 'rails_helper'
require Rails.root.join('lib', 'budget_uploader', 'budget_files').to_s

RSpec.describe 'BudgetFiles' do
  describe '#upload' do
    before :example do
      I18n.locale = 'ka'
    end

    context 'with priorities list and priority associations list' do
      before :context do
        # add some finances to allow basic testing of functionality
        # that saves priority finances from directly connected items

        create(:spending_agency)
        .add_code(attributes_for(:code, number: '45 00'))
        .add_name(attributes_for(:name, text_ka: 'საქართველოს საპატრიარქო'))
        .save_perma_id
        .add_spent_finance(attributes_for(:spent_finance,
          time_period_obj: Year.new(2013)))
        .add_spent_finance(attributes_for(:spent_finance,
          time_period_obj: Year.new(2014)))
        .add_planned_finance(attributes_for(:planned_finance,
          time_period_obj: Year.new(2013),
          announce_date: Date.new(2013, 1, 1)))
        .add_planned_finance(attributes_for(:planned_finance,
          time_period_obj: Year.new(2014),
          announce_date: Date.new(2014, 1, 1)))

        create(:program)
        .add_code(attributes_for(:code, number: '45 01'))
        .add_name(attributes_for(:name, text_ka: 'სასულიერო განათლების ხელშეწყობის გრანტი'))
        .save_perma_id
        .add_spent_finance(attributes_for(:spent_finance,
          time_period_obj: Year.new(2013)))
        .add_spent_finance(attributes_for(:spent_finance,
          time_period_obj: Year.new(2014)))
        .add_planned_finance(attributes_for(:planned_finance,
          time_period_obj: Year.new(2013),
          announce_date: Date.new(2013, 1, 1)))
        .add_planned_finance(attributes_for(:planned_finance,
          time_period_obj: Year.new(2014),
          announce_date: Date.new(2014, 1, 1)))

        create(:program)
        .add_code(attributes_for(:code, number: '45 05'))
        .add_name(attributes_for(:name, text_ka: 'საქართველოს საპატრიარქოს ბათუმის წმინდა მოწამე ეკატერინეს სახელობის სათნოების სავანისათვის გადასაცემი გრანტი'))
        .save_perma_id
        .add_spent_finance(attributes_for(:spent_finance,
          time_period_obj: Year.new(2013)))
        .add_spent_finance(attributes_for(:spent_finance,
          time_period_obj: Year.new(2014)))
        .add_planned_finance(attributes_for(:planned_finance,
          time_period_obj: Year.new(2013),
          announce_date: Date.new(2013, 1, 1)))
        .add_planned_finance(attributes_for(:planned_finance,
          time_period_obj: Year.new(2014),
          announce_date: Date.new(2014, 1, 1)))

        create(:spending_agency)
        .add_code(attributes_for(:code, number: '24 00'))
        .add_name(attributes_for(:name, text_ka: 'საქართველოს ეკონომიკისა და მდგრადი განვითარების სამინისტრო'))
        .save_perma_id

        create(:program)
        .add_code(attributes_for(:code, number: '24 01'))
        .add_name(attributes_for(:name, text_ka: 'ეკონომიკური პოლიტიკა და სახელმწიფო ქონების მართვა'))
        .save_perma_id

        create(:spending_agency)
        .add_code(attributes_for(:code, number: '08 00'))
        .add_name(attributes_for(:name, text_ka: 'საქართველოს უზენაესი სასამართლო'))
        .save_perma_id

        create(:program)
        .add_code(attributes_for(:code, number: '08 01'))
        .add_name(attributes_for(:name, text_ka: 'საქართველოს უზენაესი სასამართლო'))
        .save_perma_id

        BudgetFiles.new(
          priorities_list: BudgetFiles.priorities_list,
          priority_associations_list: BudgetFiles.priority_associations_list
        ).upload
      end

      after :context do
        Deleter.delete_all
      end

      let(:social_welfare_priority) do
        BudgetItem.find(name: 'ხელმისაწვდომი, ხარისხიანი ჯანმრთელობის დაცვა და სოციალური უზრუნველყოფა')
      end

      let(:economic_stability_priority) do
        BudgetItem.find(name: 'მაკროეკონომიკური სტაბილურობა და საინვესტიციო გარემოს გაუმჯობესება')
      end

      let(:education_priority) do
        BudgetItem.find(name: 'განათლება, მეცნიერება და პროფესიული მომზადება')
      end

      let(:defense_priority) do
        BudgetItem.find(name: 'თავდაცვა, საზოგადოებრივი წესრიგი და უსაფრთხოება')
      end

      let(:culture_priority) do
        BudgetItem.find(
          name: 'კულტურა, რელიგია, ახალგაზრდობის ხელშეწყობა და სპორტი')
      end

      it 'creates economic stability priority' do
        expect(economic_stability_priority).to_not eq(nil)

        expect(economic_stability_priority.recent_name_object.start_date)
        .to eq(Date.new(2012, 1, 1))
      end

      it 'creates perma_id for economic stability priority' do
        expect(economic_stability_priority.perma_id).to_not eq(nil)
      end

      it 'creates education priority' do
        expect(education_priority).to_not eq(nil)

        expect(education_priority.recent_name_object.start_date)
        .to eq(Date.new(2012, 1, 1))
      end

      it 'creates perma_id for education priority' do
        expect(education_priority.perma_id).to_not eq(nil)
      end

      it 'makes correct number of direct connections to welfare priority in 2012' do
        expect(
          social_welfare_priority
          .connections
          .direct
          .with_time_period(Year.new(2012))
          .length
        ).to eq(8)
      end

      it 'makes correct number of direct connections to economic stability priority in 2013' do
        expect(
          economic_stability_priority
          .connections
          .direct
          .with_time_period(Year.new(2013))
          .length
        ).to eq(15)
      end

      it 'makes correct number of direct connections to education priority in 2014' do
        expect(
          education_priority
          .connections
          .direct
          .with_time_period(Year.new(2014))
          .length
        ).to eq(17)
      end

      it 'makes correct number of direct connections to defense priority in 2015' do
        # The number of indirectly connected items listed for the defense
        # priority in the 2015 Priority PDF is actually 21. However,
        # three of these items do not appear in the yearly or monthly
        # spreadsheets, so the defense priority is only indirectly connected
        # to 18 items in 2015.
        expect(
          defense_priority
          .connections
          .direct
          .with_time_period(Year.new(2015))
          .length
        ).to eq(18)
      end

      it 'makes correct number of direct connections to culture priority in 2016' do
        expect(
          culture_priority
          .connections
          .direct
          .with_time_period(Year.new(2016))
          .length
        ).to eq(22)
      end

      it "connects program 08 01 indirectly to 08 00's directly connected priority" do
        # indirectly connected to priority სასამართლო სისტემა in 2012
        # via agency 08 00
        program_08_01 = BudgetItem.find(
          code: '08 01',
          name: 'საქართველოს უზენაესი სასამართლო'
        )

        # directly connected to priority სასამართლო სისტემა in 2012
        agency_08_00 = BudgetItem.find(
          code: '08 00',
          name: 'საქართველოს უზენაესი სასამართლო'
        )

        expect(
          program_08_01
          .priority_connections
          .indirect
          .with_time_period(Year.new(2012))[0]
          .priority
        ).to eq(
          agency_08_00
          .priority_connections
          .direct
          .with_time_period(Year.new(2012))[0]
          .priority
        )
      end

      it "indirectly connects 24 00 to 24 01's directly connected priority" do
        # indirectly connected to priority მაკროეკონომიკური... in 2012
        # via program 24 01
        agency_24_00 = BudgetItem.find(
          code: '24 00',
          name: 'საქართველოს ეკონომიკისა და მდგრადი განვითარების სამინისტრო'
        )

        # directly connected to priority მაკროეკონომიკური... in 2012
        program_24_01 = BudgetItem.find(
          code: '24 01',
          name: 'ეკონომიკური პოლიტიკა და სახელმწიფო ქონების მართვა'
        )

        expect(
          agency_24_00
          .priority_connections
          .indirect
          .with_time_period(Year.new(2012))[0]
          .priority
        ).to eq(
          program_24_01
          .priority_connections
          .direct
          .with_time_period(Year.new(2012))[0]
          .priority
        )
      end

      it 'saves spent amount for culture priority in 2013 from 45 00 agency' do
        agency45_00 = BudgetItem.find(
          code: '45 00',
          name: 'საქართველოს საპატრიარქო')

        expect(culture_priority.spent_finances
          .with_time_period(Year.new(2013)).first.amount)
        .to eq(agency45_00.spent_finances
          .with_time_period(Year.new(2013)).first.amount)
      end

      it 'saves spent amount for culture priority in 2014 from 45 00 child programs' do
        child_programs = Program.where(code: ['45 01', '45 05'])

        expect(culture_priority.spent_finances
          .with_time_period(Year.new(2014)).first.amount)
        .to eq(SpentFinance.where(finance_spendable: child_programs)
          .with_time_period(Year.new(2014)).pluck(:amount).sum)
      end

      it 'saves plan amount for culture priority in 2013 from 45 00 agency' do
        agency45_00 = BudgetItem.find(
          code: '45 00',
          name: 'საქართველოს საპატრიარქო')

        expect(culture_priority.planned_finances
          .with_time_period(Year.new(2013)).first.amount)
        .to eq(agency45_00.planned_finances
          .with_time_period(Year.new(2013)).first.amount)
      end

      it 'saves plan amount for culture priority in 2014 from 45 00 child programs' do
        child_programs = Program.where(code: ['45 01', '45 05'])

        expect(culture_priority.planned_finances
          .with_time_period(Year.new(2014)).first.amount)
        .to eq(PlannedFinance.where(finance_plannable: child_programs)
          .with_time_period(Year.new(2014)).pluck(:amount).sum)
      end
    end
  end
end
