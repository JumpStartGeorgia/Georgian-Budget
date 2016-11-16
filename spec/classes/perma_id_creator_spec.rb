require 'rails_helper'

RSpec.describe PermaIdCreator do
  describe '.new #compute' do
    context 'when name and code is provided' do
      it 'returns perma_id for name and code' do
        expect(PermaIdCreator.new(
          code: '01 01 0555',
          name: 'My funky name--'
        ).compute)
        .to eq(
          Digest::SHA1.hexdigest '01_01_0555_My_funky_name'
        )
      end
    end

    context 'when only code is provided' do
      it 'raises error' do
        expect do
          PermaIdCreator.new(code: '01 01 01 01').compute
        end.to raise_error(RuntimeError)
      end
    end

    context 'when only name is provided' do
      it 'returns perma_id for name' do
        expect(PermaIdCreator.new(name: 'My funky name--').compute).to eq(
          Digest::SHA1.hexdigest 'My_funky_name'
        )
      end
    end
  end
end
