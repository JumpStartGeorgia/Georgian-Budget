require('rails_helper')

RSpec.describe 'Budget Items API V1' do
  context 'when requesting program info and yearly finances' do
    let!(:program1) do
      FactoryGirl.create(:program)
      .add_spent_finance(FactoryGirl.attributes_for(:spent_finance,
        time_period_obj: Month.for_date(Date.new(2012, 1, 1))))
      .add_code(FactoryGirl.attributes_for(:code))
      .add_name(FactoryGirl.attributes_for(:name))
      .save_perma_id
    end

    let!(:program1_spent_2012) do
      program1.add_spent_finance(
        FactoryGirl.attributes_for(:spent_finance,
          time_period_obj: Year.new(2012)),
        return_finance: true)
    end

    let!(:program1_plan_2012) do
      program1.add_planned_finance(
        FactoryGirl.attributes_for(:planned_finance,
          time_period_obj: Year.new(2012)),
        return_finance: true)
    end

    let!(:program2) do
      FactoryGirl.create(:program)
      .add_code(FactoryGirl.attributes_for(:code))
      .add_name(FactoryGirl.attributes_for(:name))
      .save_perma_id
    end

    let!(:program3) do
      FactoryGirl.create(:program)
      .add_code(FactoryGirl.attributes_for(:code))
      .add_name(FactoryGirl.attributes_for(:name))
      .save_perma_id
    end

    let!(:program2_spent_2014) do
      program2.add_spent_finance(
        FactoryGirl.attributes_for(:spent_finance,
          time_period_obj: Year.new(2014)),
        return_finance: true)
    end

    let!(:program2_plan_2011) do
      program2.add_planned_finance(
        FactoryGirl.attributes_for(:planned_finance,
          time_period_obj: Year.new(2011)),
        return_finance: true)
    end

    let!(:program2_plan_2013) do
      program2.add_planned_finance(
        FactoryGirl.attributes_for(:planned_finance,
          time_period_obj: Year.new(2013)),
        return_finance: true)
    end

    let(:budget_items) do
      JSON.parse(response.body)['budgetItems']
    end

    let(:program1_response) do
      budget_items.find do |item_response|
        item_response['id'] == program1.perma_id
      end
    end

    let(:program2_response) do
      budget_items.find do |item_response|
        item_response['id'] == program2.perma_id
      end
    end

    before do
      FactoryGirl.create(:spending_agency)

      # exercise
      get '/en/v1',
          params: {
            budgetItemFields: 'id,name,code,type,spentFinances,plannedFinances',
            filters: {
              budgetItemType: 'program',
              timePeriodType: 'year'
            }
          },
          headers: { 'X-Key-Inflection': 'camel' }
    end

    it 'has OK status' do
      expect(response.status).to eq(200)
    end

    it 'returns correct number of budget items' do
      expect(budget_items.length).to eq(3)
    end

    it 'returns info (id, name, etc.) for each program' do
      expect(program1_response['id']).to eq(program1.perma_id)
      expect(program1_response['name']).to eq(program1.name)
      expect(program1_response['code']).to eq(program1.code)
      expect(program1_response['type']).to eq('program')

      expect(program2_response['id']).to eq(program2.perma_id)
      expect(program2_response['name']).to eq(program2.name)
      expect(program2_response['code']).to eq(program2.code)
      expect(program2_response['type']).to eq('program')
    end

    it 'returns spent finances for each program' do
      program1_spent = program1_response['spentFinances']

      expect(program1_spent.length).to eq(1)
      expect(program1_spent[0]['amount']).to eq(program1_spent_2012.amount.to_s)
      expect(program1_spent[0]['timePeriod']).to eq(program1_spent_2012.time_period)

      program2_spent = program2_response['spentFinances']
      expect(program2_spent.length).to eq(1)
      expect(program2_spent[0]['amount']).to eq(program2_spent_2014.amount.to_s)
    end

    it 'returns planned finances for each program' do
      program1_plans = program1_response['plannedFinances']
      expect(program1_plans.length).to eq(1)
      expect(program1_plans[0]['amount']).to eq(program1_plan_2012.amount.to_s)
      expect(program1_plans[0]['timePeriod']).to eq(program1_plan_2012.time_period)

      program2_plans = program2_response['plannedFinances']
      expect(program2_plans.length).to eq(2)

      program2_plan2011_response = program2_plans.find { |plan| plan['id'] === program2_plan_2011.id }
      expect(program2_plan2011_response['amount']).to eq(program2_plan_2011.amount.to_s)

      program2_plan2013_response = program2_plans.find { |plan| plan['id'] === program2_plan_2013.id }
      expect(program2_plan2013_response['amount']).to eq(program2_plan_2013.amount.to_s)
    end
  end

  context 'when requesting details for an agency' do
    let!(:overall_budget) do
      FactoryGirl.create(:total).save_perma_id
    end

    let!(:agency1) do
      q1_2015 = Quarter.for_date(Date.new(2015, 1, 1))

      FactoryGirl.create(:spending_agency)
      .add_code(FactoryGirl.attributes_for(:code, number: '043 00'))
      .add_name(FactoryGirl.attributes_for(:name))
      .save_perma_id
      .add_spent_finance(FactoryGirl.attributes_for(:spent_finance))
      .add_spent_finance(FactoryGirl.attributes_for(:spent_finance))
      .add_spent_finance(FactoryGirl.attributes_for(:spent_finance,
        amount: nil))
      .add_planned_finance(FactoryGirl.attributes_for(:planned_finance,
        time_period_obj: q1_2015))
      .add_planned_finance(FactoryGirl.attributes_for(:planned_finance,
        time_period_obj: q1_2015.next))
    end

    let!(:child_program1) do
      FactoryGirl.create(:program)
      .add_code(FactoryGirl.attributes_for(:code, number: '043 01'))
      .add_name(FactoryGirl.attributes_for(:name))
      .save_perma_id
    end

    let!(:child_program2) do
      FactoryGirl.create(:program)
      .add_code(FactoryGirl.attributes_for(:code, number: '043 02'))
      .add_name(FactoryGirl.attributes_for(:name))
      .save_perma_id
    end

    before do
      FactoryGirl.create(:program)

      get '/en/v1',
          params: {
            budgetItemFields: 'id,code,name,type,spentFinances,plannedFinances,relatedBudgetItems',
            budgetItemId: agency1.perma_id
          },
          headers: { 'X-Key-Inflection': 'camel' }
    end

    let(:json) { JSON.parse(response.body) }
    let(:agency1_response) { json['budgetItem'] }

    it 'has OK response status code and has no errors' do
      expect(response.status).to eq(200)
      expect(json['errors']).to be_empty
    end

    it 'includes basic values' do
      expect(agency1_response['id']).to eq(agency1.perma_id)
      expect(agency1_response['code']).to eq(agency1.code)
      expect(agency1_response['name']).to eq(agency1.name)
      expect(agency1_response['type']).to eq('spending_agency')
    end

    it 'returns spent finances' do
      expect(agency1_response['spentFinances'].length).to eq(3)

      response_spent_finance1 = agency1_response['spentFinances'][0]
      saved_spent_finance1 = agency1.spent_finances[0]

      expect(response_spent_finance1['id']).to eq(
        saved_spent_finance1.id)

      expect(response_spent_finance1['timePeriod']).to eq(
        saved_spent_finance1.time_period)

      expect(response_spent_finance1['timePeriodType']).to eq(
        saved_spent_finance1.time_period_obj.type)

      expect(response_spent_finance1['amount']).to eq(
        saved_spent_finance1.amount.to_s)

      response_spent_finance2 = agency1_response['spentFinances'][1]
      saved_spent_finance2 = agency1.spent_finances[1]

      expect(response_spent_finance2['id']).to eq(
        saved_spent_finance2.id)

      expect(response_spent_finance2['timePeriod']).to eq(
        saved_spent_finance2.time_period)

      expect(response_spent_finance2['timePeriodType']).to eq(
        saved_spent_finance2.time_period_obj.type)

      expect(response_spent_finance2['amount']).to eq(
        saved_spent_finance2.amount.to_s)
    end

    it 'returns planned finances' do
      expect(agency1_response['plannedFinances'].length).to eq(2)

      response_planned_finance1 = agency1_response['plannedFinances'][0]
      saved_planned_finance1 = agency1.planned_finances[0]

      expect(response_planned_finance1['id']).to eq(
        saved_planned_finance1.id)

      expect(response_planned_finance1['timePeriod']).to eq(
        saved_planned_finance1.time_period)

      expect(response_planned_finance1['timePeriodType']).to eq(
        saved_planned_finance1.time_period_obj.type)

      expect(response_planned_finance1['amount']).to eq(
        saved_planned_finance1.amount.to_s)

      response_planned_finance2 = agency1_response['plannedFinances'][1]
      saved_planned_finance2 = agency1.planned_finances[1]

      expect(response_planned_finance2['id']).to eq(
        saved_planned_finance2.id)

      expect(response_planned_finance2['timePeriod']).to eq(
        saved_planned_finance2.time_period)

      expect(response_planned_finance2['timePeriodType']).to eq(
        saved_planned_finance2.time_period_obj.type)

      expect(response_planned_finance2['amount']).to eq(
        saved_planned_finance2.amount.to_s)
    end

    it 'includes related budget items' do
      overall_budget_response = agency1_response['overallBudget']
      expect(overall_budget_response['id']).to eq(overall_budget.perma_id)

      child_programs_response_ids = agency1_response['childPrograms'].map { |p| p['id'] }

      expect(child_programs_response_ids.length).to eq(2)
      expect(child_programs_response_ids).to contain_exactly(
        child_program1.perma_id, child_program2.perma_id
      )
    end
  end

  context 'when requesting total budget' do
    let!(:overall_budget) do
      FactoryGirl.create(:total).save_perma_id
    end

    let!(:priorities) do
      FactoryGirl.create_list(:priority, 2).each do |priority|
        priority
        .add_name(FactoryGirl.attributes_for(:name))
        .save_perma_id
      end
    end

    let!(:spending_agencies) do
      FactoryGirl.create_list(:spending_agency, 3).each do |spending_agency|
        spending_agency
        .add_name(FactoryGirl.attributes_for(:name))
        .add_code(FactoryGirl.attributes_for(:code))
        .save_perma_id
      end
    end

    before do
      get '/en/v1',
          params: {
            budgetItemFields: 'id,relatedBudgetItems',
            budgetItemId: overall_budget.perma_id
          },
          headers: { 'X-Key-Inflection': 'camel' }
    end

    let(:json) { JSON.parse(response.body) }
    let(:overall_budget_response) { json['budgetItem'] }

    it 'returns related items' do
      expect(overall_budget_response['overallBudget']).to eq(nil)

      priority_ids_response = overall_budget_response['priorities']
        .map { |priority_response| priority_response['id'] }

      expect(priority_ids_response).to contain_exactly(
        *priorities.map(&:perma_id))

      agency_ids_response = overall_budget_response['spendingAgencies']
        .map { |agency_response| agency_response['id'] }

      expect(agency_ids_response).to contain_exactly(
        *spending_agencies.map(&:perma_id))
    end
  end

  context 'when requesting subprogram with child programs' do
    let!(:overall_budget) do
      FactoryGirl.create(:total).save_perma_id
    end

    let!(:other_agency) do
      FactoryGirl.create(:spending_agency)
      .add_code(FactoryGirl.attributes_for(:code, number: '02 00'))
      .add_name(FactoryGirl.attributes_for(:name))
      .save_perma_id
    end

    let!(:agency) do
      FactoryGirl.create(:spending_agency)
      .add_code(FactoryGirl.attributes_for(:code, number: '01 00'))
      .add_name(FactoryGirl.attributes_for(:name))
      .save_perma_id
    end

    let!(:parent_program) do
      FactoryGirl.create(:program)
      .add_code(FactoryGirl.attributes_for(:code, number: '01 01'))
      .add_name(FactoryGirl.attributes_for(:name))
      .save_perma_id
    end

    let!(:program) do
      program = FactoryGirl.create(:program)
      .add_code(FactoryGirl.attributes_for(:code, number: '01 01 02'))
      .add_name(FactoryGirl.attributes_for(:name))
      .save_perma_id
    end

    let!(:child_program1) do
      FactoryGirl.create(:program)
      .add_code(FactoryGirl.attributes_for(:code, number: '01 01 02 04'))
      .add_name(FactoryGirl.attributes_for(:name))
      .save_perma_id
    end

    let!(:child_program2) do
      FactoryGirl.create(:program)
      .add_code(FactoryGirl.attributes_for(:code, number: '01 01 02 05'))
      .add_name(FactoryGirl.attributes_for(:name))
      .save_perma_id
    end

    before do
      get '/en/v1',
          params: {
            budgetItemFields: 'id,relatedBudgetItems',
            budgetItemId: program.perma_id
          },
          headers: { 'X-Key-Inflection': 'camel' }
    end

    let(:json) { JSON.parse(response.body) }
    let(:program_response) { json['budgetItem'] }

    it 'includes related items' do
      expect(program_response['overallBudget']['id']).to eq(overall_budget.perma_id)

      child_program_response_ids = program_response['childPrograms'].map { |p| p['id'] }
      expect(child_program_response_ids).to contain_exactly(
        child_program1.perma_id,
        child_program2.perma_id
      )

      expect(program_response['parentProgram']['id']).to eq(parent_program.perma_id)
      expect(program_response['spendingAgency']['id']).to eq(agency.perma_id)
    end
  end
end
