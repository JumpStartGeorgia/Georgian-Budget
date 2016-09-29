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
end
