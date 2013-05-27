require 'spec_helper'

describe Visit::Factory do
  let(:user) { create :user }

  before do
    Visit::Event.destroy_all
  end

  context "events that have labels" do
    let (:h1) { new_request_payload_hash url: "http://e.org/articles" }
    let (:h2) { new_request_payload_hash url: "http://e.org/articles/1" }
    let (:a_request_payload) { [ h1, h2 ] }

    it "create traits" do
      expect {
        Visit::Factory.run a_request_payload
      }.to change { Visit::Trait.count }.by(3)
    end
  end


  context "events that have labels and other key/value pairs" do
    let (:h1) { new_request_payload_hash url: "http://e.org/articles?utm_campaign=aaa&utm_source=" }
    let (:a_request_payload) { [ h1 ] }

    it "create traits" do
      expect {
        Visit::Factory.run a_request_payload
      }.to change { Visit::Trait.count }.by(3)
    end
  end

end
