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
        Visit::DestroyUnused.new.events!
      }.to change { Visit::Event.count }.by(-1)
    end

    it "does nothing during a dry run" do
      expect {
        Visit::DestroyUnused.new(dry_run: true).events!
      }.to change { Visit::Event.count }.by(0)
    end

    it "deletes sources that are dependent on deleted events" do
      expect {
        Visit::DestroyUnused.new.events!
      }.to change { Visit::Source.count }.by(-1)
    end

    it "leaves alone events that aren't ignored" do
      url_id = Visit::SourceValue.where(v: 'http://a.com')

      expect {
        Visit::DestroyUnused.new.events!
      }.to change { Visit::Event.where(url_id: url_id).count }.by(0)
    end

    it "doesn't change SourceValue" do
      expect {
        Visit::DestroyUnused.new.events!
      }.to change { Visit::SourceValue.count }.by(0)
    end
  end

  context "#sources!" do
    def create_unused_source
      s = Visit::Source.new
      s.k_id = Visit::SourceValue.first.id
      s.v_id = Visit::SourceValue.first.id
      s.visit_event_id = Visit::Event.first.id
      s.save!
    end

    before do
      h1 = new_request_payload_hash cookies: { "flip_fred" => "blah" }
      Visit::Factory.new.run [ h1 ]
      create_unused_source
    end

    it "deletes sources that aren't in Configurable.cookies_match" do
      expect {
        Visit::DestroyUnused.new.sources!
      }.to change { Visit::Source.count }.by(-1)
    end

    it "does nothing during a dry run" do
      expect {
        Visit::DestroyUnused.new(dry_run: true).sources!
      }.to change { Visit::Source.count }.by(0)
    end

    it "leaves alone sources that aren't ignored" do
      k_id = Visit::SourceValue.where(v: 'flip_fred')

      expect {
        Visit::DestroyUnused.new.sources!
      }.to change { Visit::Source.where(k_id: k_id).count }.by(0)
    end

    it "doesn't change SourceValue" do
      expect {
        Visit::DestroyUnused.new.sources!
      }.to change { Visit::SourceValue.count }.by(0)
    end
  end

  context "#sources_values!" do
    def create_unused_source_value
      sv = Visit::SourceValue.new
      sv.v = "xxx"
      sv.save!
    end

    context "with unused source_values present" do
      before { create_unused_source_value }

      it "deletes unused source_values" do
        expect {
          Visit::DestroyUnused.new.source_values!
        }.to change { Visit::SourceValue.count }.by(-1)
      end

      it "does nothing during a dry run" do
        expect {
          Visit::DestroyUnused.new(dry_run: true).source_values!
        }.to change { Visit::SourceValue.count }.by(0)
      end
    end

    context "with unused source_values present" do
      it "does nothing" do
        expect {
          Visit::DestroyUnused.new.source_values!
        }.to change { Visit::SourceValue.count }.by(0)
      end
    end
  end
end



