module Csv
  class PriorityConnections
    attr_reader :locale

    def initialize(args)
      @locale = args[:locale]
    end

    def export
      require 'csv'

      I18n.with_locale locale do
        CSV.open(file_path, 'wb') do |csv|
          csv << headers
          rows.each do |row|
            csv << row
          end
        end
      end
    end

    private

    def file_path
      file_dir.join(filename)
    end

    def file_dir
      Rails.root.join('tmp', 'csv')
    end

    def filename
      "priority_connections_#{locale}.csv"
    end

    def headers
      [
        'Priority Name',
        'Item Name',
        'Item Code',
        'Item Type',
        'Time Period'
      ]
    end

    def rows
      PriorityConnection.all.map do |priority_connection|
        other_item = priority_connection.priority_connectable
        [
          priority_connection.priority.name,
          other_item.name,
          other_item.code,
          other_item.class.to_s,
          priority_connection.time_period_obj.to_s
        ]
      end
    end
  end
end
