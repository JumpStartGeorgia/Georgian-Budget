class FinanceCategorizer
  def initialize(finance)
    @finance = finance
  end

  def set_primary
    if versions.count == 1
      finance.update_attributes(primary: true) unless finance.primary
      return
    end

    versions.update(primary: false)
    primary_version.update_attributes(primary: true) unless primary_version.blank?
  end

  private

  attr_reader :finance

  def versions
    finance.versions
  end

  def official_versions
    versions.official
  end

  def unofficial_versions
    versions.unofficial
  end

  def primary_version
    @primary_version ||= get_primary_version
  end

  def get_primary_version
    if official_versions.count > 0
      if announceable?
        return official_versions.order(:announce_date).last
      else
        return official_versions.last
      end
    else
      if announceable?
        return unofficial_versions.order(:announce_date).last
      else
        return unofficial_versions.last
      end
    end

    nil
  end

  def announceable?
    finance.respond_to?(:announce_date)
  end
end
