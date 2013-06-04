require 'spec_helper'

describe Visit::Event do
  it "creates only one source value for identical urls" do
    url = "http://www.example.com"
    first = create(:visit_event, url: url)
    second = create(:visit_event, url: url)
    first.url_id.should == second.url_id
  end

  describe ".path_from_url" do
    let(:url) { '/foo/bar' }

    context "given a path" do
      it "returns the path" do
        expect(Visit::Event.path_from_url(url)).to eq('/foo/bar')
      end
    end

    context "given a scheme, host and path" do
      let(:url) { 'http://example.com/foo/bar' }

      it "returns the path" do
        expect(Visit::Event.path_from_url(url)).to eq('/foo/bar')
      end
    end

    context "given a scheme, host, path and port" do
      let(:url) { 'http://example.com/foo/bar' }

      it "returns the path" do
        expect(Visit::Event.path_from_url(url)).to eq('/foo/bar')
      end
    end
  end

end
