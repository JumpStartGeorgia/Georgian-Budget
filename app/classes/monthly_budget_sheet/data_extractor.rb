module MonthlyBudgetSheet
  class DataExtractor
    def extract_from_item(item)
      {
        start_date: item.start_date,
        primary_code: item.primary_code,
        name_text: item.name,
        spent_finance_cumulative: item.cumulative_spent_finance_amount,
        planned_finance_cumulative: item.cumulative_planned_finance_amount,
        warnings: item.warnings
      }
    end
  end
end
