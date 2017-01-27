class PrimaryFinancesZipper
  def initialize
  end

  def export
    PrimaryFinancesCSVExporter.new('yearly', 'ka').export
  end
end
