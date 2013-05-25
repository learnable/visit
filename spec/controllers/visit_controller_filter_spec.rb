require 'spec_helper'
require 'shared_gem_config'

describe "Visit::ControllerFilters", type: :controller do
  # Create an rspec anonymous controller, which by default inherits from
  # ActionController::Base
  controller do
    def index
      head :ok
    end
  end

  let(:token) { 555 }

  context "session[:token]" do
    it "should be set when there's no token cookie" do
      get :index
      session.should have_key(:token)
      session[:token].length.should == Visit::Event.token_length
    end
    it "should not be set when there's a token cookie" do
      @request.cookies["token"] = token
      get :index
      session.should_not have_key(:token)
    end
  end

  context "#set_event" do

    before :each do
      Visit::Event.destroy_all
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

    it "should create exactly one VisitEvent when a token visits exactly once" do
      do_some_visits
      a_event = Visit::Event.find_all_by_token(token_next)
      a_event.should have(1).records
      a_event.first.token.should == token_next
      a_event.first.user_id.should == user_id
      a_event.first.http_method.to_s.should == request.method.downcase
    end

    it "should create multiple VisitEvents when a token visits multiple times" do
      do_some_visits
      Visit::Event.find_all_by_token(token).should have(3).records
    end

  end

end
