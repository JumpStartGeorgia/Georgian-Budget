require 'rails_helper'
require Rails.root.join('lib', 'budget_uploader', 'budget_files').to_s

RSpec.describe 'BudgetFiles' do
  describe '#upload with duplicate items csv' do
    context 'when items marked as non duplicates' do
      it 'resolves pair and does not merge items' do
        item1 = create(:program)
        create(:code, number: '24 01 03', codeable: item1)
        create(:name, text_ka: 'ელექტრონული კომუნიკაციების საინფორმაციო ტექნოლოგიებისა და საფოსტო კავშირის განვითარება', nameable: item1)
        item1.save_perma_id

        item2 = create(:program)
        create(:code, number: '24 01 03', codeable: item2)
        create(:name, text_ka: 'მეწარმეობის განვითარება', nameable: item2)
        item2.save_perma_id

        pair = create(:possible_duplicate_pair, item1: item1, item2: item2)

        BudgetFiles.new(
          duplicate_pairs_file: BudgetFiles.duplicate_pairs_file
        ).upload

        expect(
          BudgetItem.find(code: '24 01 03', name: 'ელექტრონული კომუნიკაციების საინფორმაციო ტექნოლოგიებისა და საფოსტო კავშირის განვითარება')
        ).to_not eq(
          BudgetItem.find(code: '24 01 03', name: 'მეწარმეობის განვითარება')
        )

        expect(
          PossibleDuplicatePair.where(item1: item1, item2: item2).empty?
        ).to eq(true)
      end
    end

    context 'when items marked as duplicates and name not significant' do
      it 'resolves pair and merges items' do
        item1 = create(:spending_agency)
        create(:code, number: '04 00', codeable: item1)
        create(:name, text_ka: 'საქართველოს მთავრობის კანცელარია', nameable: item1)
        item1.save_perma_id

        item2 = create(:spending_agency)
        create(:code, number: '04 00', codeable: item2)
        create(:name, text_ka: 'საქართველოს მთავრობის ადმინისტრაცია', nameable: item2)
        item2.save_perma_id

        pair = create(:possible_duplicate_pair, item1: item1, item2: item2)

        BudgetFiles.new(
          duplicate_pairs_file: BudgetFiles.duplicate_pairs_file
        ).upload

        expect(
          BudgetItem.find(code: '04 00', name: 'საქართველოს მთავრობის კანცელარია')
        ).to eq(
          BudgetItem.find(code: '04 00', name: 'საქართველოს მთავრობის ადმინისტრაცია')
        )

        expect(
          PossibleDuplicatePair.where(item1: item1, item2: item2).empty?
        ).to eq(true)
      end
    end
  end
end
