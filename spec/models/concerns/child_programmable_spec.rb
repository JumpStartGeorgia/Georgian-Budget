require 'rails_helper'

RSpec.shared_examples_for 'ChildProgrammable' do
  let(:described_class_sym) { described_class.to_s.underscore.to_sym }
  let(:child_programmable) { FactoryGirl.create(described_class_sym)}

  describe '#child_programs' do
    it 'returns programs that point to child_programmable' do
      child1 = FactoryGirl.create(:program)
      child1.update_attribute(:parent, child_programmable)

      child2 = FactoryGirl.create(:program)
      child2.update_attribute(:parent, child_programmable)

      child_programmable.reload
      expect(child_programmable.child_programs).to include(child1, child2)
    end
  end
end
