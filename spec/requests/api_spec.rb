require('rails_helper')

RSpec.describe 'API' do
  context 'when version is not v1' do
    it 'responds with version error' do
      get '/en/v2'

      json = JSON.parse(response.body)
      error = json['errors'][0]

      expect(response.status).to eq(400)
      expect(error['text']).to eq('API version "v2" does not exist')
    end
  end

  context 'when requesting list of program ids and names' do
    it 'returns the perma_ids and names of all programs' do
      program1 = FactoryGirl.create(:program)
      .add_code(FactoryGirl.attributes_for(:code))
      .add_name(FactoryGirl.attributes_for(:name))
      .save_perma_id

      program2 = FactoryGirl.create(:program)
      .add_code(FactoryGirl.attributes_for(:code))
      .add_name(FactoryGirl.attributes_for(:name))
      .save_perma_id

      FactoryGirl.create(:spending_agency)

      get '/en/v1',
          params: {
            budgetItemFields: 'id,name',
            filters: {
              budgetItemType: 'program'
            }
          },
          headers: { 'X-Key-Inflection': 'camel' }

      json = JSON.parse(response.body)
      budget_items = json['budgetItems']

      expect(response.status).to eq(200)

      expect(budget_items[0]['id']).to eq(program1.perma_id)
      expect(budget_items[0]['name']).to eq(program1.name)

      expect(budget_items[1]['id']).to eq(program2.perma_id)
      expect(budget_items[1]['name']).to eq(program2.name)
    end
  end

  context 'when requesting details for two budget items' do
    let!(:program1) do
      q1_2015 = Quarter.for_date(Date.new(2015, 1, 1))

      FactoryGirl.create(:program)
      .add_code(FactoryGirl.attributes_for(:code))
      .add_name(FactoryGirl.attributes_for(:name))
      .save_perma_id
      .add_spent_finance(FactoryGirl.attributes_for(:spent_finance))
      .add_spent_finance(FactoryGirl.attributes_for(:spent_finance,
        amount: nil))
      .add_planned_finance(FactoryGirl.attributes_for(:planned_finance,
        time_period_obj: q1_2015))
      .add_planned_finance(FactoryGirl.attributes_for(:planned_finance,
        time_period_obj: q1_2015.next))
    end

    let!(:agency1) do
      FactoryGirl.create(:spending_agency)
      .add_code(FactoryGirl.attributes_for(:code))
      .add_name(FactoryGirl.attributes_for(:name))
      .save_perma_id
      .add_spent_finance(FactoryGirl.attributes_for(:spent_finance))
      .add_spent_finance(FactoryGirl.attributes_for(:spent_finance))
      .add_spent_finance(FactoryGirl.attributes_for(:spent_finance))
      .add_planned_finance(FactoryGirl.attributes_for(:planned_finance))
    end

    before do
      get '/en/v1',
          params: {
            budgetItemFields: 'id,code,name,type,spent_finances,planned_finances',
            budgetItemIds: [program1.perma_id, agency1.perma_id]
          },
          headers: { 'X-Key-Inflection': 'camel' }
    end

    let(:json) { JSON.parse(response.body) }
    let(:program1_response) { json['budgetItems'][0] }
    let(:agency1_response) { json['budgetItems'][1] }

    it 'has OK response status code and has no errors' do
      expect(response.status).to eq(200)
      expect(json['errors']).to be_empty
    end

    it 'includes program basic values' do
      expect(program1_response['id']).to eq(program1.perma_id)
      expect(program1_response['code']).to eq(program1.code)
      expect(program1_response['name']).to eq(program1.name)
      expect(program1_response['type']).to eq('program')
    end

    it 'returns program spent finances' do
      expect(program1_response['spentFinances'].length).to eq(2)

      response_spent_finance1 = program1_response['spentFinances'][0]
      saved_spent_finance1 = program1.spent_finances[0]

      expect(response_spent_finance1['id']).to eq(
        saved_spent_finance1.id)

      expect(response_spent_finance1['timePeriod']).to eq(
        saved_spent_finance1.time_period)

      expect(response_spent_finance1['timePeriodType']).to eq(
        saved_spent_finance1.time_period_obj.type)

      expect(response_spent_finance1['amount']).to eq(
        saved_spent_finance1.amount.to_s)

      response_spent_finance2 = program1_response['spentFinances'][1]
      saved_spent_finance2 = program1.spent_finances[1]

      expect(response_spent_finance2['id']).to eq(
        saved_spent_finance2.id)

      expect(response_spent_finance2['timePeriod']).to eq(
        saved_spent_finance2.time_period)

      expect(response_spent_finance2['timePeriodType']).to eq(
        saved_spent_finance2.time_period_obj.type)

      expect(response_spent_finance2['amount']).to eq(
        saved_spent_finance2.amount)
    end

    it 'returns program planned finances' do
      expect(program1_response['plannedFinances'].length).to eq(2)

      response_planned_finance1 = program1_response['plannedFinances'][0]
      saved_planned_finance1 = program1.planned_finances[0]

      expect(response_planned_finance1['id']).to eq(
        saved_planned_finance1.id)

      expect(response_planned_finance1['timePeriod']).to eq(
        saved_planned_finance1.time_period)

      expect(response_planned_finance1['timePeriodType']).to eq(
        saved_planned_finance1.time_period_obj.type)

      expect(response_planned_finance1['amount']).to eq(
        saved_planned_finance1.amount.to_s)

      response_planned_finance2 = program1_response['plannedFinances'][1]
      saved_planned_finance2 = program1.planned_finances[1]

      expect(response_planned_finance2['id']).to eq(
        saved_planned_finance2.id)

      expect(response_planned_finance2['timePeriod']).to eq(
        saved_planned_finance2.time_period)

      expect(response_planned_finance2['timePeriodType']).to eq(
        saved_planned_finance2.time_period_obj.type)

      expect(response_planned_finance2['amount']).to eq(
        saved_planned_finance2.amount.to_s)
    end

    it 'includes agency data' do
      expect(agency1_response['id']).to eq(agency1.perma_id)
      expect(agency1_response['code']).to eq(agency1.code)
      expect(agency1_response['name']).to eq(agency1.name)
      expect(agency1_response['type']).to eq('spending_agency')

      expect(agency1_response['spentFinances'].length).to eq(3)
      expect(agency1_response['plannedFinances'].length).to eq(1)
    end
  end

  context 'when budget_type filter is not allowed value' do
    it "don't allow it!"
  end

  context 'when budget_item_fields includes not allowed fields' do
    it "throw an error!"
  end
end
