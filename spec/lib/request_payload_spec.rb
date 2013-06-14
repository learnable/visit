require 'spec_helper'

describe Visit::RequestPayload do
  let (:request_payload_hash) { new_request_payload_hash }
  subject { Visit::RequestPayload.new request_payload_hash }

  it "can be constructed, given a hash with symbol as keys" do
    request_payload_hash.each { |k,v| subject[k].should == v }
  end

  it "can be constructed, given a hash with strings as keys" do
    request_payload = Visit::RequestPayload.new request_payload_hash.stringify_keys
    request_payload_hash.each { |k,v| subject[k].should == v }
  end

  it "#to_values should return all the values" do
    subject.to_values.should == [ "https://earl.io?utm_campaign=qqq", "mozilla", "http://blah.com", "a", "b", "c", "d" ]
  end

  it "#to_pairs should return the cookies" do
    subject.to_pairs.should have(1).item
    subject.to_pairs.first[:k_id].should == Visit::SourceValue.where(v: :a).first.id
    subject.to_pairs.first[:v_id].should == Visit::SourceValue.where(v: :b).first.id
  end

end
