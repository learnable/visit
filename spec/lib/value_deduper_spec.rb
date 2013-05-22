require 'spec_helper'
require 'shared_gem_config'
require 'shared_duplicate_values'

shared_examples "a nice deduper" do |model_class_pair, model_class_value|
  before {
    Duplicate.create_duplicates_for_value(model_class_value)
    Duplicate.create_duplicates_for_pair(model_class_pair, model_class_value)
  }

  context "and in the Value model" do
    it "delete the duplicate rows" do
      Visit::ValueDeduper.run

      Duplicate.starting_point(model_class_value).map(&:v).each do |v|
        model_class_value.where(v: v).count.should == 1
      end
    end
  
    it "not delete any other rows" do
      expect {
        Visit::ValueDeduper.run
      }.to change { Visit::Query::DuplicateValue.new(model_class_value).scoped.all.count }.by(-3)
    end
  end

  it "leave no Traits referencing duplicate values" do
    id_duplicates = Duplicate.id_duplicates(model_class_value)

    Visit::ValueDeduper.run

    Visit::Query::PairsReferencingValues.new(model_class_pair, id_duplicates).scoped.count.should == 0
  end
end

describe Visit::ValueDeduper do

  before { Duplicate.setup }

  context "#run" do
    context "in the presence of duplicate TraitValues" do
      it_should_behave_like "a nice deduper", Visit::Trait, Visit::TraitValue
    end
    context "in the presence of duplicate SourceValues" do
      it_should_behave_like "a nice deduper", Visit::Source, Visit::SourceValue
    end
    context "in the presence of duplicate SourceValues and duplicate Events" do
      before {
        Duplicate.create_duplicates_for_value(Visit::SourceValue)
        Duplicate.create_duplicates_for_pair(Visit::Source, Visit::SourceValue)
        Duplicate.create_duplicates_for_event(Visit::SourceValue)
      }
      
      it "leave no Traits referencing duplicate values" do
        id_duplicates = Duplicate.id_duplicates(Visit::SourceValue)

        Visit::ValueDeduper.run

        Visit::Query::EventsReferencingValues.new(id_duplicates).scoped.count.should == 0
      end
    end
  end
end
