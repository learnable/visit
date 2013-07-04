require 'spec_helper'

describe Visit::RailsRequestContext do
  context "in a controller", type: :controller do
    controller do
      def index
        head :ok
      end
      def show
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

      context "the :url key has the correct scheme, host, query params etc" do
        it "when the url is supplied via the Rails request" do
          get :index, foo: "bar"

          url = new_rails_request_context(cookies: {}).to_h[:url]

          expect(url).to match(/\?foo=bar/)
          expect(url).to match(Regexp.new(request.host))
          expect(url).to match(Regexp.new(request.scheme))
        end

        it "when the path is hardcoded" do
          get :show, id: 3, aaa: "bbb"

          url = new_rails_request_context({ cookies: { "token" => "123"}, must_insert: true, hardcoded_path: "/fred?foo=bar" }).to_h[:url]

          expect(url).to match(/\/fred\?foo=bar/)
          expect(url).to match(Regexp.new(request.host))
          expect(url).to match(Regexp.new(request.scheme))
        end
      end
    end

  end
end
