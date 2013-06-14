require 'spec_helper'

describe Visit::RequestPayload do
  let (:request_payload_hash) {
    request_payload_hash = new_request_payload_hash
    request_payload_hash[:cookies]["flip_blah"] = nil
    request_payload_hash
  }
  subject { Visit::RequestPayload.new request_payload_hash }

  it "can be constructed, given a hash with symbol as keys" do
    request_payload_hash.each { |k,v| subject[k].should == v }
  end

  it "can be constructed, given a hash with strings as keys" do
    request_payload = Visit::RequestPayload.new request_payload_hash.stringify_keys
    request_payload_hash.each { |k,v| subject[k].should == v }
  end

  it "#to_values should return all the values" do
    subject.to_values.sort.should == [ "https://earl.io?utm_campaign=qqq", "mozilla", "http://blah.com", "a", "b", "flip_blah", "" ].sort
  end

  it "#to_pairs should return the cookies" do
    subject.to_pairs.should have(2).item
    subject.to_pairs.first[:k_id].should == Visit::SourceValue.where(v: :a).first.id
    subject.to_pairs.first[:v_id].should == Visit::SourceValue.where(v: :b).first.id
    subject.to_pairs.second[:k_id].should == Visit::SourceValue.where(v: :flip_blah).first.id
    subject.to_pairs.second[:v_id].should == Visit::SourceValue.where(v: "").first.id
  end

  context "when referer is nil" do
    let (:request_payload_hash) {
      request_payload_hash = new_request_payload_hash
      request_payload_hash[:referer] = nil
      request_payload_hash
    }
    subject { Visit::RequestPayload.new request_payload_hash }

    it "#to_values handles it by mapping nil to ''" do
      subject.to_values.sort.should == [ "https://earl.io?utm_campaign=qqq", "mozilla", "a", "b", "" ].sort
    end
  end

end
