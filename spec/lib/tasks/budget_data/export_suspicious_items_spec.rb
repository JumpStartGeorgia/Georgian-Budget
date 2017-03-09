require 'rails_helper'

RSpec.describe 'rake budget_data:export_suspicious_items' do
  let(:directory_path) { Rails.root.join('spec', 'tmp', 'suspicious_items') }

  after :each do
    require 'fileutils'
    FileUtils.rm_rf(directory_path) if File.exist?(directory_path)
  end

  it 'outputs a directory of three CSVs' do
    GeorgianBudget::Application.load_tasks

    Rake::Task['budget_data:export_suspicious_items'].invoke(directory_path)

    expect(File.exist?(directory_path)).to eq(true)
  end
end
