require('rails_helper')

RSpec.describe 'Page Contents API V1' do
  context 'when requesting about page content' do
    let!(:about_page_content) do
      create(:page_content, name: 'about')
    end

    it 'returns about page content' do
      get '/en/v1/page_contents/about'

      json = JSON.parse(response.body)
    end
  end
end
