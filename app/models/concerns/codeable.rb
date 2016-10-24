module Codeable
  extend ActiveSupport::Concern

  included do
    validates :code, presence: true
  end
end
