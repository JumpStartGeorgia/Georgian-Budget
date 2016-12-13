module PriorityAssociations
  class Row
    attr_reader :code_number,
                :type,
                :name,
                :priority_identifier,
                :year_number,
                :priorities_list,
                :row_number

    def initialize(row, args)
      @code_number = row[0]
      @type = row[1]
      @name = row[2]
      # priority num corresponds to the number in priorities_list
      @priority_identifier = row[3]
      @year_number = row[4].blank? ? nil : row[4].to_i

      @priorities_list = args[:priorities_list]
      @row_number = args[:row_number]
    end

    def start_date
      year.start_date
    end

    def publish_date
      start_date
    end

    def end_date
      year.end_date
    end

    def year
      @year ||= Year.new(year_number)
    end

    def code_data
      {
        number: code_number,
        start_date: year.start_date
      }
    end

    def name_data
      {
        text_ka: name,
        start_date: year.start_date
      }
    end

    def priority_connection_data
      {
        direct: true,
        priority: priority,
        time_period_obj: year
      }
    end

    def data_missing?
      return true if code_number.blank?
      return true if type.blank?
      return true if name.blank?
      return true if priority_identifier.blank?
      return true if priority.blank?
      return true if year.blank?

      return false
    end

    private

    def priority
      @priority ||= get_priority
    end

    def get_priority
      return nil if priority_identifier == 'NA'
      priorities_list.get_priority_from_identifier(priority_identifier)
    end
  end
end
