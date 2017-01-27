# NOT TESTED
class CsvController < ApplicationController
  def primary_finances
    locale = params[:locale]
    filename = "primary_finances_#{locale}.zip"
    send_file Rails.root.join('public', 'system', 'csv', filename)
  end
end
