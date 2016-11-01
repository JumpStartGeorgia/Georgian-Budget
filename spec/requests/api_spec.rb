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

  context 'when budget_type filter is program' do
    context 'and budget_item_fields is id,name' do
      it 'gets the ids and names of all programs' do
        program1 = FactoryGirl.create(:program).add_name(
          FactoryGirl.attributes_for(:name))
          
        program2 = FactoryGirl.create(:program).add_name(
          FactoryGirl.attributes_for(:name))

        agency1 = FactoryGirl.create(:spending_agency)

        params = {
          budgetItemFields: 'id,name',
          filters: {
            budgetItemType: 'program'
          }
        }

        get '/en/v1', params: params

        json = JSON.parse(response.body)
        budget_items = json['budgetItems']

        expect(response.status).to eq(200)

        expect(budget_items[0]['id']).to eq(program1.id)
        expect(budget_items[0]['name']).to eq(program1.name)

        expect(budget_items[1]['id']).to eq(program2.id)
        expect(budget_items[1]['name']).to eq(program2.name)
      end
    end
  end

  context 'when budget_type filter is not allowed value' do
    it "don't allow it!"
  end

  context 'when budget_item_fields includes not allowed fields' do
    it "throw an error!"
  end
end
