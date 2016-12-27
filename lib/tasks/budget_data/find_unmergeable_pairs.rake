namespace :budget_data do
  desc 'find unmergeable possible duplicate pairs'
  task find_unmergeable_pairs: :environment do
    I18n.locale = 'ka'

    require Rails.root.join('lib', 'budget_uploader', 'budget_files')

    DuplicatePairsList
    .new(BudgetFiles.duplicate_pairs_file)
    .output_unmergeable_pairs
  end
end
