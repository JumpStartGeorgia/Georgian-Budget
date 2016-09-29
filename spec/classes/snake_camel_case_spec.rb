require 'rails_helper'

RSpec.describe SnakeCamelCase do
  let(:snake_case_object) do
    {
      hello_johnny: 'johnny_hello',
      hello_bobby: {
        woo_smith: 'fdff',
        foo_smith: 123
      },
      hi_guy: {
        fun_gun: [
          {
            woop_doop: 56
          },
          {
            foo_boo: 'sillyWilly'
          }
        ]
      }
    }
  end

  let(:camel_case_object) do
    {
      helloJohnny: 'johnny_hello',
      helloBobby: {
        wooSmith: 'fdff',
        fooSmith: 123
      },
      hiGuy: {
        funGun: [
          {
            woopDoop: 56
          },
          {
            fooBoo: 'sillyWilly'
          }
        ]
      }
    }
  end

  describe '.to_camel_case_sym' do
    it 'converts all nested keys to camel case' do
      expect(SnakeCamelCase.to_camel_case_sym(snake_case_object)).to eq(
        camel_case_object
      )
    end
  end
end
