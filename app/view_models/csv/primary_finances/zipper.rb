module Csv
  module PrimaryFinances
    class Zipper
      def initialize
      end

      def export
        Csv::PrimaryFinances::FileExporter.new(
          time_period_type: 'yearly',
          locale: 'ka'
        ).export
      end
    end
  end
end
