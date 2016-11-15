class PermaIdCreator
  def self.for_budget_item(budget_item)
    new(Hash.new.tap do |hash|
      if budget_item.respond_to?(:name)
        if budget_item.name_ka.present?
          hash[:name] = budget_item.name_ka
        else
          hash[:missing_data] = true
        end
      end

      if budget_item.respond_to?(:code)
        if budget_item.code.present?
          hash[:code] = budget_item.code
        else
          hash[:missing_data] = true
        end
      end
    end)
  end

  def initialize(args)
    @name = args[:name]
    @code = args[:code]
    @missing_data = args[:missing_data]

    if name.blank?
      raise 'Cannot create a perma id without a name'
    end
  end

  def compute
    return nil if missing_data
    computed_sha1
  end

  attr_reader :name,
              :code,
              :missing_data

  private

  def computed_sha1
    return nil unless name.present? || code.present?

    if name.present? && code.present?
      string_id = "#{prepared_code}_#{prepared_name}"
    elsif name.present?
      string_id = "#{prepared_name}"
    elsif code.present?
      string_id = "#{prepared_code}"
    end

    Digest::SHA1.hexdigest(string_id)
  end

  def prepared_code
    code.gsub(' ', '_')
  end

  def prepared_name
    Name.aggressively_clean_text(name).gsub(' ', '_')
  end
end
