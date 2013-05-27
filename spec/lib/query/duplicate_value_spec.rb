require 'spec_helper'

shared_examples "a Query" do |model_class|
  before {
    DuplicateFixture.create_duplicates_for_value(model_class)
  }

  subject { Visit::Query::DuplicateValue.new(model_class) }

  it "#scoped finds the duplicate values" do
    subject.scoped.pluck(:v).sort.should == DuplicateFixture.starting_point(model_class).map(&:v).sort
  end
end

describe Visit::Query::DuplicateValue do
  before { DuplicateFixture.setup }

  context "when there are duplicate TraitValues" do
    it_should_behave_like "a Query", Visit::TraitValue
  end

  context "when there are duplicate SourceValues" do
    it_should_behave_like "a Query", Visit::SourceValue
  end
end
