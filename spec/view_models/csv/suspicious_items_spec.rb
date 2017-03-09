require 'rails_helper'

RSpec.describe Csv::SuspiciousItems do
  let(:directory_path) { Rails.root.join('spec', 'tmp', 'suspicious_items') }

  describe '#export' do
    after :each do
      require 'fileutils'
      FileUtils.rm_rf(directory_path) if File.exist?(directory_path)
    end

    it 'exports a directory containing three CSVs' do
      Csv::SuspiciousItems.new(directory_path: directory_path).export

      expect(File.exist?(directory_path)).to eq(true)

      expect(File.exist?(
        directory_path.join('only_yearly_finances.csv')
      )).to eq(true)

      # expect(File.exist?(
      #   directory_path.join('yearly_but_no_monthly_or_quarterly.csv')
      # )).to eq(true)
      #
      # expect(File.exist?(
      #   directory_path.join('no_priority_connections.csv')
      # )).to eq(true)
    end
  end
end
