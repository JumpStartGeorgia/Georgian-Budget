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

      get '/en/v1', params: {
        budgetItemFields: 'id,name',
        filters: {
          budgetItemType: 'program'
        }
      }

      json = JSON.parse(response.body)
      budget_items = json['budgetItems']

      expect(response.status).to eq(200)

      expect(budget_items[0]['id']).to eq(program1.perma_id)
      expect(budget_items[0]['name']).to eq(program1.name)

      expect(budget_items[1]['id']).to eq(program2.perma_id)
      expect(budget_items[1]['name']).to eq(program2.name)
    end
  end

  context 'when budget_type filter is not allowed value' do
    it "don't allow it!"
  end

  context 'when budget_item_fields includes not allowed fields' do
    it "throw an error!"
  end
end
