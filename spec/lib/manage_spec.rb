require 'spec_helper'

describe Visit::Manage do
  before do
    start_with_visits [
      { url: "http://a.com" },
      { url: "http://a.com" },
      { url: "http://a.com/system/blah" },
    ]
  end

  context "#destroy_ignorable" do
    it "deletes events that are ignored" do
      expect {
        Visit::Manage.destroy_ignorable
      }.to change { Visit::Event.count }.by(-1)
    end

    it "leaves alone events that aren't ignored" do
      url_id = Visit::SourceValue.where(v: 'http://a.com')

      expect {
        Visit::Manage.destroy_ignorable
      }.to change { Visit::Event.where(url_id: url_id).count }.by(0)
    end
  end

  context "#destroy_sources_if_not_used" do
    before do
      h1 = new_request_payload_hash cookies: { "flip_fred" => "blah" }
      Visit::Factory.new.run [ h1 ]
    end

    it "deletes sources that aren't in Configurable.cookies_match" do
      expect {
        Visit::Manage.destroy_sources_if_not_used { |a| puts "AMHEREX: #{a}"}
      }.to change { Visit::Source.count }.by(-6)
    end

    it "leaves alone events that aren't ignored" do
      k_id = Visit::SourceValue.where(v: 'flip_fred')

      expect {
        Visit::Manage.destroy_ignorable
      }.to change { Visit::Source.where(k_id: k_id).count }.by(0)
    end
  end

end


