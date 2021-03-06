require 'spec_helper'

describe Visit::Event do
  it "creates only one source value for identical urls" do
    url = "http://www.example.com"
    first = create(:visit_event, url: url)
    second = create(:visit_event, url: url)
    first.url_id.should == second.url_id
  end

  describe ".path" do
    shared_examples "a pathfinder" do |url, path|
      let(:event) { create(:visit_event, url: url) }

      it "returns the path" do
        expect(event.path).to eq(path)
      end
    end

    context "given a path" do
      it_should_behave_like "a pathfinder", "/foo/bar", "/foo/bar"
    end

    context "given a scheme, host and path" do
      it_should_behave_like "a pathfinder", "http://example.com/foo/bar)", "/foo/bar)"
    end

    context "given a scheme and path" do
      it_should_behave_like "a pathfinder", "file:///bar", "/bar"
    end

    context "given a scheme, host, path and port" do
      it_should_behave_like "a pathfinder", "http://example.com:8080/foo/bar", "/foo/bar"
    end

    context "given a scheme, host, path, port, query string and fragment" do
      it_should_behave_like "a pathfinder", "http://example.com:8080/foo/bar?a=b#c", "/foo/bar?a=b#c"
    end
  end

  context "#source_value_ids" do
    before { start_with_visits [ { url: "http://e.org/articles" } ] }

    let (:event) { Visit::Query::MatchFirst.new.scoped.where("url_vsv.v" => "http://e.org/articles").first }

    it "returns the source_values" do
      event.source_value_ids.sort.should == Visit::SourceValue.all.map(&:id).sort
    end
  end

end
