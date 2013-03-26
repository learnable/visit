require 'spec_helper'

describe Visit::Event do
  it "creates only one source value for identical urls" do
    url = "http://www.example.com"
    first = create(:visit_event, url: url)
    second = create(:visit_event, url: url)
    first.url_id.should == second.url_id
  end
end
