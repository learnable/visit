require 'spec_helper'

describe Visit::Cache::Key do
  subject { Visit::Cache::Key.new("abc", 123) }

  context "when a key's parts are 'abc' and 123" do
    its(:key) { should =~ /abc/ }
    its(:key) { should =~ /123/ }
  end
  
end
