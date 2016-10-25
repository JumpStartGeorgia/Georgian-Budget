require 'rails_helper'
require Rails.root.join('lib', 'budget_uploader', 'budget_files').to_s

RSpec.describe 'BudgetFiles' do
  describe '#upload with monthly_folder' do
    it 'saves names of agencies and programs in monthly spreadsheets' do
      # setup
      monthly_budgets_start_date = Date.new(2015, 01, 01)
      I18n.locale = 'ka'

      month_files_dir = BudgetFiles.monthly_spreadsheet_dir.join('2015')

      # exercise
      BudgetFiles.new(
        monthly_paths: [
          month_files_dir.join('monthly_spreadsheet-01.2015.xlsx').to_s,
          month_files_dir.join('monthly_spreadsheet-02.2015.xlsx').to_s
        ],
        budget_item_translations: BudgetFiles.english_translations_file
      ).upload

      # verify
      # TOTAL
      total = Total.first

      expect(total.code).to eq('00')

      expect(total.name_en).to eq('Total Georgian Budget')
      expect(total.name_ka).to eq('მთლიანი სახელმწიფო ბიუჯეტი')

      # Total: spent
      total_spent_finance1 = total.spent_finances[0]
      total_spent_finance2 = total.spent_finances[1]

      expect(total.spent_finances.length).to eq(2)

      expect(total_spent_finance1.amount.to_f).to eq(656549486.69)
      expect(total_spent_finance1.start_date).to eq(Date.new(2015, 1, 1))
      expect(total_spent_finance1.end_date).to eq(Date.new(2015, 1, 31))

      expect(total_spent_finance2.amount.to_f).to eq(641341973.31)
      expect(total_spent_finance2.start_date).to eq(Date.new(2015, 2, 1))
      expect(total_spent_finance2.end_date).to eq(Date.new(2015, 2, 28))

      # Total: planned
      total_planned_finances = total.all_planned_finances
      total_planned_finance1 = total_planned_finances[0]

      expect(total_planned_finances.length).to eq(1)

      expect(total_planned_finance1.amount.to_f).to eq(2162575900)
      expect(total_planned_finance1.start_date).to eq(Date.new(2015, 1, 1))
      expect(total_planned_finance1.end_date).to eq(Date.new(2015, 3, 31))
      expect(total_planned_finance1.announce_date).to eq(Date.new(2015, 1, 1))
      expect(total_planned_finance1.most_recently_announced).to eq(true)

      ### SPENDING AGENCY 1
      spending_agency1_array = SpendingAgency.find_by_name('საქართველოს პარლამენტი და მასთან არსებული ორგანიზაციები')
      spending_agency1 = spending_agency1_array[0]

      expect(spending_agency1_array.length).to eq(1)
      expect(spending_agency1.code).to eq('01 00')
      expect(spending_agency1.recent_name_object.start_date).to eq(monthly_budgets_start_date)

      # agency1: spent
      spending_agency1_spent_finance1 = spending_agency1.spent_finances[0]
      spending_agency1_spent_finance2 = spending_agency1.spent_finances[1]

      expect(spending_agency1.spent_finances.length).to eq(2)

      expect(spending_agency1_spent_finance1.amount.to_f).to eq(3532432.91)
      expect(spending_agency1_spent_finance1.start_date).to eq(Date.new(2015, 1, 1))
      expect(spending_agency1_spent_finance1.end_date).to eq(Date.new(2015, 1, 31))

      expect(spending_agency1_spent_finance2.amount.to_f).to eq(3753083.38)
      expect(spending_agency1_spent_finance2.start_date).to eq(Date.new(2015, 2, 1))
      expect(spending_agency1_spent_finance2.end_date).to eq(Date.new(2015, 2, 28))

      # agency1: planned
      spending_agency1_planned_finances = spending_agency1.all_planned_finances
      spending_agency1_planned_finance1 = spending_agency1_planned_finances[0]

      expect(spending_agency1_planned_finances.length).to eq(1)

      expect(spending_agency1_planned_finance1.amount.to_f).to eq(14767400)
      expect(spending_agency1_planned_finance1.start_date).to eq(Date.new(2015, 1, 1))
      expect(spending_agency1_planned_finance1.end_date).to eq(Date.new(2015, 3, 31))
      expect(spending_agency1_planned_finance1.announce_date).to eq(Date.new(2015, 1, 1))
      expect(spending_agency1_planned_finance1.most_recently_announced).to eq(true)

      ### SPENDING AGENCY
      spending_agency2_array = SpendingAgency.find_by_name('საქართველოს მთავრობის ადმინისტრაცია')
      spending_agency2 = spending_agency2_array[0]

      expect(spending_agency2_array.length).to eq(1)
      expect(spending_agency2.code).to eq('04 00')
      expect(spending_agency2.name).to eq('საქართველოს მთავრობის ადმინისტრაცია')

      # this spending agency changes plans from january to february, so it
      # has two plans for the same quarter
      spending_agency2_planned_finances = spending_agency2.all_planned_finances
      spending_agency2_planned_finance1 = spending_agency2_planned_finances[0]
      spending_agency2_planned_finance2 = spending_agency2_planned_finances[1]

      expect(spending_agency2_planned_finance1.amount.to_f).to eq(11471000)
      expect(spending_agency2_planned_finance1.start_date).to eq(Date.new(2015, 1, 1))
      expect(spending_agency2_planned_finance1.end_date).to eq(Date.new(2015, 3, 31))
      expect(spending_agency2_planned_finance1.announce_date).to eq(Date.new(2015, 1, 1))
      expect(spending_agency2_planned_finance1.most_recently_announced).to eq(false)

      expect(spending_agency2_planned_finance2.amount.to_f).to eq(12471000)
      expect(spending_agency2_planned_finance2.start_date).to eq(Date.new(2015, 1, 1))
      expect(spending_agency2_planned_finance2.end_date).to eq(Date.new(2015, 3, 31))
      expect(spending_agency2_planned_finance2.announce_date).to eq(Date.new(2015, 2, 1))
      expect(spending_agency2_planned_finance2.most_recently_announced).to eq(true)

      ### PROGRAM
      program1_array = Program.find_by_name('საკანონმდებლო საქმიანობა')
      program1 = program1_array[0]

      expect(program1_array.length).to eq(1)
      expect(program1.code).to eq('01 01')
      expect(program1.recent_name_object.start_date).to eq(monthly_budgets_start_date)

      ###
      spending_agency2_array = SpendingAgency.find_by_name('საქართველოს პრეზიდენტის ადმინისტრაცია')
      spending_agency2 = spending_agency2_array[0]

      expect(spending_agency2_array.length).to eq(1)
      expect(spending_agency2.code).to eq('02 00')
      expect(spending_agency2.recent_name_object.start_date).to eq(monthly_budgets_start_date)

      ###
      program2_array = Program.find_by_name('საქართველოს ეროვნული უშიშროების საბჭოს აპარატი')
      program2 = program2_array[0]

      expect(program2_array.length).to eq(1)
      expect(program2.code).to eq('03 01')
      expect(program2.recent_name_object.start_date).to eq(monthly_budgets_start_date)

      ### Checking translations
      public_funds_management = Program.find_by_code('23 01')

      expect(public_funds_management.name_ka).to eq(
        'სახელმწიფო ფინანსების მართვა'
      )

      expect(public_funds_management.name_en).to eq(
        'Public Funds Management'
      )
    end
  end

  describe '#upload with priorities list and priority associations list' do
    it 'creates priorities and associates them with other budget items' do
      # Setup parliament agency
      parliament = SpendingAgency.create(code: '01 00')
      Name.create(
        nameable: parliament,
        text_ka: 'საქართველოს პარლამენტი და მასთან არსებული ორგანიზაციები',
        start_date: Date.new(2012, 1, 1)
      )

      # Setup audit regulation program
      audit_regulation_program = Program.create(code: '01 02')
      Name.create(
        nameable: audit_regulation_program,
        text_ka: 'აუდიტორული საქმიანობის სახელმწიფო რეგულირება',
        start_date: Date.new(2012, 1, 1)
      )

      # Setup library program
      library_program = Program.create(code: '01 02')
      Name.create(
        nameable: library_program,
        text_ka: 'საბიბლიოთეკო საქმიანობა',
        start_date: Date.new(2013, 1, 1)
      )

      # Exercise
      BudgetFiles.new(
        priorities_list: BudgetFiles.priorities_list,
        priority_associations_list: BudgetFiles.priority_associations_list
      ).upload

      # Verify economic stability priority
      economic_stability_priority = Priority.find_by_name(
        'მაკროეკონომიკური სტაბილურობა და საინვესტიციო გარემოს გაუმჯობესება'
      )[0]

      expect(economic_stability_priority).to_not eq(nil)

      expect(economic_stability_priority.recent_name_object.start_date)
      .to eq(Date.new(2012, 1, 1))

      # Verify education priority
      education_priority = Priority.find_by_name(
        'განათლება, მეცნიერება და პროფესიული მომზადება'
      )[0]

      expect(education_priority).to_not eq(nil)

      expect(education_priority.recent_name_object.start_date)
      .to eq(Date.new(2012, 1, 1))

      # Verify uncategorized Priority
      uncategorized_priority = Priority.find_by_name('უკატეგორიო')[0]

      expect(uncategorized_priority).to_not eq(nil)
      expect(uncategorized_priority.recent_name_object.start_date)
      .to eq(Date.new(2012, 1, 1))

      # Verify parliament
      parliament.reload
      expect(parliament.priority).to eq(uncategorized_priority)

      # Verify audit regulation program
      audit_regulation_program.reload
      expect(audit_regulation_program.priority).to eq(economic_stability_priority)

      # Verify library program
      library_program.reload
      expect(library_program.priority).to eq(education_priority)
    end
  end

  describe '#upload with english translations' do
    it 'saves English translations of names' do
      program = FactoryGirl.create(
        :program,
        code: '23 01'
      )

      FactoryGirl.create(
        :name,
        text_ka: 'სახელმწიფო ფინანსების მართვა',
        text_en: '',
        start_date: Date.new(2015, 1, 1),
        nameable: program
      )

      BudgetFiles.new(
        budget_item_translations: BudgetFiles.english_translations_file
      ).upload

      expect(program.name_en).to eq(
        'Public Funds Management'
      )
    end
  end
end
