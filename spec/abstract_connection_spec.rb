require 'spec_helper'

describe 'ActiveRecord::ConnectionAdapters::AbstractAdapter' do
  it "responds to create_view" do
    ::ActiveRecord::ConnectionAdapters::AbstractAdapter.new(nil).should respond_to(:create_view)
  end
end
