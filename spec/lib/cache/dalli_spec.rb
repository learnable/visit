require 'spec_helper'

describe Visit::Cache::Dalli do
  it_should_behave_like "Cache" do
    let(:cache) do
      Visit::Cache::Dalli.new \
        ActiveSupport::Cache.lookup_store \
          :dalli_store,
          "127.0.0.1:11211",
          { :namespace => "#{Rails.application.class.parent_name}::visit::rspec", :expires_in => 1.hour }
    end
  end
end
