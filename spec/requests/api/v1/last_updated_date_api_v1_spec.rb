require('rails_helper')

RSpec.describe 'Last Updated Date API V1' do
  context 'when request is for last updated date' do
    let!(:finance) do
      create_list(:spent_finance, 3)
    end

    it 'returns latest created at date for spent finances' do
      get '/en/v1/last_updated_date'

      json = JSON.parse(response.body)

      expect(json['last_updated_date'])
      .to eq(Date.today.to_s)
    end
  end
end
