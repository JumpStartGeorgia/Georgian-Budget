class YearlyBudgetSheet::ItemDataCompiler
  def initialize(yearly_sheet_item, args)
    @yearly_sheet_item = yearly_sheet_item
    @year = args[:year]
  end

  def code_number
    yearly_sheet_item.code_number
  end

  def code_data
    {
      start_date: year.start_date,
      number: code_number
    }
  end

  def name_data
    {
      start_date: year.start_date,
      text_en: nil,
      text_ka: yearly_sheet_item.name_ka
    }
  end

  def spent_finance_data
    return nil if yearly_sheet_item.two_years_earlier_spent_amount.blank?

    two_years_ago = year.previous.previous

    {
      time_period_obj: two_years_ago,
      amount: yearly_sheet_item.two_years_earlier_spent_amount,
      official: true
    }
  end

  def planned_finance_data
    finances = []

    if yearly_sheet_item.previous_year_plan_amount.present?
      previous_year = year.previous

      finances << {
        time_period_obj: previous_year,
        announce_date: year.start_date,
        amount: yearly_sheet_item.previous_year_plan_amount,
        official: true
      }
    end

    if yearly_sheet_item.current_year_plan_amount.present?
      finances << {
        time_period_obj: year,
        announce_date: year.start_date,
        amount: yearly_sheet_item.current_year_plan_amount,
        official: true
      }
    end

    finances
  end

  def publish_date
    year.start_date
  end

  attr_reader :yearly_sheet_item,
              :year
end
