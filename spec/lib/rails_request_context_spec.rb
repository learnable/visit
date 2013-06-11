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
      ret.session = session

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

    context "#to_h" do
      context "for key :cookies, the value" do
        subject {
          new_rails_request_context(cookies: { "flip_aaa" => "aaa", "flip_bbb" => "bbb" }).to_h
        }

        it "is a Hash" do
          subject.should be_a_kind_of(Hash)
        end

        it "contains flip_blah when a flip_blah cookie is present" do
          subject[:cookies].should have_key("flip_aaa")
          subject[:cookies].should have_key("flip_bbb")

          subject[:cookies]["flip_aaa"].should == "aaa"
          subject[:cookies]["flip_bbb"].should == "bbb"
        end
      end
    end

  end
end
