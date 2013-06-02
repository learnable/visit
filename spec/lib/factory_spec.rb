require 'spec_helper'

describe Visit::Factory do
  before do
    delete_all_visits
  end

  context "events that have labels" do
    it "create traits" do
      h1 = new_request_payload_hash url: "http://e.org/articles"
      h2 = new_request_payload_hash url: "http://e.org/articles/1"

      expect {
        Visit::Factory.new.run [ h1, h2 ]
      }.to change { Visit::Trait.count }.by(3)
    end
  end

  context "events that have labels and other key/value pairs" do
    it "create traits" do
      h1 = new_request_payload_hash url: "http://e.org/articles?utm_campaign=aaa&utm_source="

      expect {
        Visit::Factory.new.run [ h1 ]
      }.to change { Visit::Trait.count }.by(3)
    end
  end

end
