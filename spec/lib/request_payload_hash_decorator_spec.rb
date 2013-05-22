require 'spec_helper'
require 'shared_gem_config'

describe Visit::RequestPayloadHashDecorator do
  subject {
    Visit::RequestPayloadHashDecorator.new new_request_payload_hash
  }

  it "#to_values should return all the values" do
    subject.to_values.should == [ "https://earl.io?utm_campaign=qqq", "mozilla", "http://blah.com", "a", "b", "c", "d" ]
  end

  pending "to_pairs" do
  end

end
