require 'spec_helper'

describe Visit::DestroyUnused do
  before do
    start_with_visits [
      { url: "http://a.com" },
      { url: "http://a.com" },
      { url: "http://a.com/system/blah" },
    ]
  end

  context "#events!" do
    it "deletes events that are ignored" do
      expect {
        Visit::DestroyUnused.events!
      }.to change { Visit::Event.count }.by(-1)
    end

    it "deletes sources that are dependent on deleted events" do
      expect {
        Visit::DestroyUnused.events!
      }.to change { Visit::Source.count }.by(-2)
    end

    it "leaves alone events that aren't ignored" do
      url_id = Visit::SourceValue.where(v: 'http://a.com')

      expect {
        Visit::DestroyUnused.events!
      }.to change { Visit::Event.where(url_id: url_id).count }.by(0)
    end

    it "doesn't change SourceValue" do
      expect {
        Visit::DestroyUnused.events!
      }.to change { Visit::SourceValue.count }.by(0)
    end
  end

  context "#sources!" do
    before do
      h1 = new_request_payload_hash cookies: { "flip_fred" => "blah" }
      Visit::Factory.new.run [ h1 ]
    end

    it "deletes sources that aren't in Configurable.cookies_match" do
      expect {
        Visit::DestroyUnused.sources!
      }.to change { Visit::Source.count }.by(-6)
    end

    it "leaves alone sources that aren't ignored" do
      k_id = Visit::SourceValue.where(v: 'flip_fred')

      expect {
        Visit::DestroyUnused.sources!
      }.to change { Visit::Source.where(k_id: k_id).count }.by(0)
    end

    it "doesn't change SourceValue" do
      expect {
        Visit::DestroyUnused.sources!
      }.to change { Visit::SourceValue.count }.by(0)
    end
  end
end


