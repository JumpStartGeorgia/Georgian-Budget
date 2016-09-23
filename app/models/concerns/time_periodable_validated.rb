module TimePeriodableValidated
  extend ActiveSupport::Concern
  include TimePeriodable

  included do
    validates_with StartEndDateValidator
  end
end
