require 'spec_helper'

describe Visit::SerializedString do
  def encoded(x); Visit::SerializedString.new(x).encode; end
  def decoded(x); Visit::SerializedString.new(x).decode; end

  it "has #encode and #decode" do
    decoded(encoded("fred")).should == "fred"
  end

  it "#encode returns an object that can be serialized as JSON" do
    decoded(JSON.parse(encoded("fred").to_json)).should == "fred"
  end
end
