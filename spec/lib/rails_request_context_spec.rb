require 'spec_helper'

describe Visit::RailsRequestContext do
  context "in a controller", type: :controller do
    controller do
      def index
        head :ok
      end
    end

    def new_rails_request_context(opts = {})
      ret = Visit::RailsRequestContext.new
      ret.request = @request
      ret.path = nil

      opts.each { |k,v| ret[k] = v }

      ret
    end

    context "#ignorable?" do
      it "returns true when is_ignorable == true AND when the path is ignorable" do
        new_rails_request_context({ is_ignorable: true, path: "/system/blah" }).ignorable?.should be_true
      end
      it "returns false when the path is ignorable" do
        new_rails_request_context({ is_ignorable: false, path: "/system/blah" }).ignorable?.should be_false
      end
      it "returns false when rails_request_context.is_ignorable" do
        new_rails_request_context({ is_ignorable: true, path: "/fred" }).ignorable?.should be_false
      end
      it "returns false when both rails_request_context.is_ignorable and path is ignorable" do
        new_rails_request_context({ is_ignorable: false, path: "/fred" }).ignorable?.should be_false
      end
    end

  end
end
