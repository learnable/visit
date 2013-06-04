require 'spec_helper'

describe "Visit::ControllerFilters", type: :controller do
  # Create an rspec anonymous controller, which by default inherits from
  # ActionController::Base
  controller do
    def index
      head :ok
    end
  end

  let(:token) { "0123456789123456" }

  shared_examples "a non altering controller filter" do
    context "when cookie contains a token" do
      it "should not alter session" do
        @request.cookies["token"] = token
        get :index
        session.should_not have_key("token")
      end
    end

    context "when session contains a token" do
      it "should not alter cookies" do
        session["token"] = token
        get :index
        @request.cookies.should_not have_key("token")
      end
    end
  end

  context "#set_visit_token" do
    context "when Configurable.is_token_cookie_set_in(:visit_tag_controller)" do
      before do
        Visit::Configurable.configure do |c|
          c.is_token_cookie_set_in = ->(sym) do
            sym == :visit_tag_controller
          end
        end
      end

      context "when neither session nor cookie contains a token" do
        it_should_behave_like "a non altering controller filter"

        it "should set token in the session (and not cookie)" do
          get :index
          session.should have_key("token")
          session["token"].length.should == Visit::Event::TOKEN_LENGTH
          @request.cookies.should_not have_key("token")
        end
      end

    end

    context "when Configurable.is_token_cookie_set_in(:application_controller)" do
      before do
        Visit::Configurable.configure do |c|
          c.is_token_cookie_set_in = ->(sym) do
            sym == :application_controller
          end
        end
      end

      context "when neither session nor cookie contains a token" do
        it_should_behave_like "a non altering controller filter"

        it "should set token in the cookie (and not session)" do
          get :index

          response.cookies.should have_key("token")
          response.cookies["token"].length.should == Visit::Event::TOKEN_LENGTH
          session.should_not have_key("token")
        end
      end
    end
  end

  context "as a basic acceptance test, after some visits" do

    before do
      delete_all_visits
      do_some_visits
    end

    let(:token_next) { "556" }
    let(:user_id) { 444 }

    def do_visit(path, token = token, uid = user_id)
      @request.stub(:path) { path }
      @request.cookies["token"] = token
      if user_id
        create :user, id: user_id if !User.exists?(user_id)
        o = double
        o.stub(:id) { uid }
        @controller.stub(:current_user) { o }
      end
      get :index
    end

    def do_some_visits
      do_visit "/"                                # X visits
      do_visit "/learn/css"                       # X visits again
      do_visit "/courses/xx-123"                  # X visits again
      do_visit "/courses/blah.js"                 # ignored visit
      do_visit "/system/blah"                     # ignored visit
      do_visit "/teach", token_next, user_id      # Y visits
    end

    context "when a token visits exactly once" do
      it "should create exactly one Visit::Event" do
        a_event = Visit::Event.find_all_by_token(token_next)
        a_event.should have(1).records
        a_event.first.token.should == token_next
        a_event.first.user_id.should == user_id
        a_event.first.http_method.to_s.should == request.method.downcase
      end
    end

    context "when a token visits multiple times" do
      it "should create multiple Visit::Events" do
        Visit::Event.find_all_by_token(token).should have(3).records
      end
    end

    context "when a logged-in user visits" do
      it "the Visit::Event should have .user_id set" do
        Visit::Event.where(token: token_next).first.user_id.should == user_id
      end
    end
  end
end
