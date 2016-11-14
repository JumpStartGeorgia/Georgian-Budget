module ChildProgrammable
  extend ActiveSupport::Concern

  included do
    has_many :child_programs,
             class_name: 'Program',
             as: :parent
  end
end
