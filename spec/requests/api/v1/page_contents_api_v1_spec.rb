require('rails_helper')

RSpec.describe 'Page Contents API V1' do
  context 'when requesting about page content' do
    let!(:about_page_content) do
      create(:page_content, name: 'about', content: 'Hellooo bla bla')
    end

    it 'returns about page content' do
      get '/en/v1/page_contents/about'

      json = JSON.parse(response.body)

      expect(json['content']).to eq(about_page_content.content)
    end
  end
end
