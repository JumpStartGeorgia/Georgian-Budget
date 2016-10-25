module PriorityAssociations
  class Row
    def initialize(row, args)
      @code = row[0]
      @type = row[1]
      @name = row[2]
      # priority num corresponds to the number in priorities_list
      @priority_identifier = row[3]
      @year = row[4]

      @priorities_list = args[:priorities_list]
      @row_number = args[:row_number]

      @priority = nil
      @budget_item = nil
    end

    def save
      return false if data_missing?

      budget_item.priority = priority
      budget_item.save!
    end

    attr_reader :code,
                :type,
                :name,
                :priority_identifier,
                :year,
                :priorities_list,
                :row_number

    def budget_item
      @budget_item ||= get_budget_item
    end

    def priority
      @priority ||= get_priority
    end

    private

    def data_missing?
      return true if code.blank?
      return true if type.blank?
      return true if name.blank?
      return true if priority_identifier.blank?
      return true if year.blank?
      return true if budget_item.blank?
      return true if priority.blank?

      return false
    end

    def get_budget_item
      klass.find_by_name(name).where(code: code)[0]
    end

    def klass
      return SpendingAgency if type == 'spending agency'
      return Program if type.include?('program')
      raise "Could not determine class for priority associations list row #{row_number}"
    end

    def get_priority
      priorities_list.get_priority_from_identifier(priority_identifier)
    end
  end
end
