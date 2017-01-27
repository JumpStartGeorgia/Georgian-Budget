module Csv
  module PrimaryFinances
    class Zipper
      def initialize
      end

      def export
        Csv::PrimaryFinances::FileExporter.new('yearly', 'ka').export
      end
    end
  end
end
