class PermaIdCreator
  def initialize(args)
    @name = args[:name]
    @code = args[:code]

    if name.blank?
      raise 'Cannot create a perma id without a name'
    end
  end

  def compute
    computed_sha1
  end

  attr_reader :name,
              :code

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
