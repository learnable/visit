require 'spec_helper'

describe Visit::Cache::Key do
  subject { Visit::Cache::Key.new("abc", 123) }

  its(:key) { should =~ /abc/ }
  its(:key) { should =~ /123/ }
  
end
