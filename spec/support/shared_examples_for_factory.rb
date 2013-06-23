shared_examples "Factory" do

  before { delete_all_visits }

  context "with some requests" do
    let(:h1) { new_request_payload_hash url: "http://e.org/articles" }
    let(:h2) { new_request_payload_hash url: "http://e.org/articles/1" }
    let(:h3) { new_request_payload_hash url: "http://e.org/articles" }

    context "in one run of the factory" do
      before { factory_run [ h1, h2 ] }

      it "Traits are created" do
        Visit::Trait.count.should == 3
      end

      it "SourceValues are created" do
        Visit::SourceValue.count.should == 6
      end

      it "TraitValues are created" do
        Visit::TraitValue.count.should == 5
      end
    end

    context "in two runs of the factory" do
      before do
        factory_run [ h1, h2 ]
        factory_run [ h3 ]
      end

      it "not too many SourceValues are created" do
        Visit::SourceValue.count.should == 6
      end

      it "not too many TraitValues are created" do
        Visit::TraitValue.count.should == 5
      end
    end
  end

  context "events that have labels and other key/value pairs" do
    it "create traits" do
      h1 = new_request_payload_hash url: "http://e.org/articles?utm_campaign=aaa&utm_source="

      expect {
        factory_run [ h1 ]
      }.to change { Visit::Trait.count }.by(3)
    end
  end

  context "events that match to match_all traits" do
    it "create traits" do
      h1 = new_request_payload_hash url: "http://e.org/articles?invite=aaa&trait_no_value"

      expect {
        factory_run [ h1 ]
      }.to change { Visit::Trait.count }.by(3)
    end
  end
end
