require 'spec_helper'

shared_examples "a nice deduper" do |model_class_pair, model_class_value|
  before {
    DuplicateFixture.create_duplicates_for_value model_class_value
    DuplicateFixture.create_duplicates_for_pair model_class_pair, model_class_value
  }

  context "and in the Value model" do
    it "delete the duplicate rows" do
      Visit::Deduper.new.run

      DuplicateFixture.starting_point(model_class_value).map(&:v).each do |v|
        model_class_value.where(v: v).count.should == 1
      end
    end
  
    it "not delete any other rows" do
      expect {
        Visit::Deduper.new.run
      }.to change { Visit::Query::DuplicateValue.new(model_class_value).scoped.all.count }.by(-3)
    end
  end

  it "leave no Traits referencing duplicate values" do
    id_duplicates = DuplicateFixture.id_duplicates model_class_value

    Visit::Deduper.new.run

    Visit::Query::PairsReferencingValues.new(model_class_pair, id_duplicates).scoped.count.should == 0
  end
end

describe Visit::Deduper do
  before { DuplicateFixture.setup }

  context "#run" do
    context "in the presence of duplicate TraitValues" do
      it_should_behave_like "a nice deduper", Visit::Trait, Visit::TraitValue
    end

    context "in the presence of duplicate SourceValues" do
      it_should_behave_like "a nice deduper", Visit::Source, Visit::SourceValue
    end

    context "in the presence of duplicate SourceValues and duplicate Events" do
      before {
        DuplicateFixture.create_duplicates_for_value Visit::SourceValue
        DuplicateFixture.create_duplicates_for_pair Visit::Source, Visit::SourceValue
        DuplicateFixture.create_duplicates_for_event Visit::SourceValue
      }
      
      it "leave no Traits referencing duplicate values" do
        id_duplicates = DuplicateFixture.id_duplicates Visit::SourceValue

        Visit::Deduper.new.run

        Visit::Query::EventsReferencingValues.new(id_duplicates).scoped.count.should == 0
      end
    end
  end
end
