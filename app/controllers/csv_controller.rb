# NOT TESTED
class CsvController < ApplicationController
  def complete_primary_finances
    locale = params[:locale]
    filename = "complete_primary_finances_#{locale}.zip"
    filepath = Rails.root.join('public', 'system', 'csv', filename)
    if (File.exist?(filepath))
      send_file filepath
    else
      render json: 'File does not exist. Please notify JumpStart Georgia of this issue.', status: 404
    end
  end
end
