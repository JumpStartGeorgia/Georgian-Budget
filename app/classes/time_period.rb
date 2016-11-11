# Parent class of time periods like Month, Quarter, and Year
# Not meant for direct use
class TimePeriod
  def type
    self.class.type_to_s
  end

  def self.type_to_s
    self.to_s.downcase
  end
end
