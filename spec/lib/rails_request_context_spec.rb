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
      ret.hardcoded_path = nil
      ret.session = session

      opts.each { |k,v| ret[k] = v }

      ret
    end

    context "#ignorable?" do
      it "returns true when must_insert == false AND when the path is ignorable" do
        new_rails_request_context({ must_insert: false, hardcoded_path: "/system/blah" }).ignorable?.should be_true
      end
      it "returns false when the path is ignorable" do
        new_rails_request_context({ must_insert: true, hardcoded_path: "/system/blah" }).ignorable?.should be_false
      end
      it "returns false when must_insert == false and the path isn't ignorable'" do
        new_rails_request_context({ must_insert: false, hardcoded_path: "/fred" }).ignorable?.should be_false
      end
      it "returns false when must_insert == true and the path isn't ignorable" do
        new_rails_request_context({ must_insert: true, hardcoded_path: "/fred" }).ignorable?.should be_false
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

      it "does not remove query parameters" do
        get :index, foo: "bar"

        url = new_rails_request_context(cookies: {}).to_h[:url]

        expect(url).to eq("http://test.host/anonymous?foo=bar")
      end
    end

  end
end
