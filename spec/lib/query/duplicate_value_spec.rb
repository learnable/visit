require 'spec_helper'
require 'shared_gem_config'
require 'shared_duplicate_values'

shared_examples "a Query" do |model_class|
  before {
    Duplicate.create_duplicates_for_value(model_class)
  }

  subject { Visit::Query::DuplicateValue.new(model_class) }

  it "#scoped finds the duplicate values" do
    subject.scoped.pluck(:v).sort.should == Duplicate.starting_point(model_class).map(&:v).sort
  end
end

describe Visit::Query::DuplicateValue do
  before { Duplicate.setup }

  context "when there are duplicate TraitValues" do
    it_should_behave_like "a Query", Visit::TraitValue
  end

  context "when there are duplicate SourceValues" do
    it_should_behave_like "a Query", Visit::SourceValue
  end
end
