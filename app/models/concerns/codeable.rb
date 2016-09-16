module Codeable
  extend ActiveSupport::Concern

  included do
    validates :code, presence: true, uniqueness: true
  end
end
