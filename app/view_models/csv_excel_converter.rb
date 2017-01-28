class CsvExcelConverter
  def initialize
  end

  def convert_csv(csv_filepath, output_path)
    require 'spreadsheet'

    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet

    header_format = Spreadsheet::Format.new(
      :weight => :bold,
      :horizontal_align => :center,
      :locked => true
    )

    sheet1.row(0).default_format = header_format

    require 'csv'

    CSV.open(csv_filepath, 'r') do |csv|
      csv.each_with_index do |row, i|
        sheet1.row(i).replace(row)
      end
    end

    book.write(output_path)
  end
end
