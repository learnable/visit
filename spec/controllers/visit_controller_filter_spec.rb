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

  let(:visit_id) { 555 }

  context "session[:visit_id]" do
    it "should be set when there's no visit_id cookie" do
      get :index
      session.should have_key(:vid)
      session[:vid].should be > 0
    end
    it "should not be set when there's a visit_id cookie" do
      @request.cookies["vid"] = visit_id
      get :index
      session.should_not have_key(:vid)
    end
  end

  context "#set_event" do

    before :each do
      Visit::Trait.delete_all
      Visit::Event.delete_all
    end

    let(:visit_id_next) { 556 }
    let(:user_id) { 444 }

    def do_visit(path, vid = visit_id, uid = user_id)
      @request.stub(:path) { path }
      @request.cookies["vid"] = vid
      if user_id
        create :user, id: user_id if !User.exists?(user_id)
        o = double
        o.stub(:id) { uid }
        o.stub(:_agreement_version) { 2 }
        o.stub("has_broken_payment_device?") { false }
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
      do_visit "/teach", visit_id_next, user_id   # Y visits
    end

    it "should create exactly one VisitEvent when a visit_id visits exactly once" do
      do_some_visits
      a_event = Visit::Event.find_all_by_vid(visit_id_next)
      a_event.should have(1).records
      a_event.first.vid.should == visit_id_next
      a_event.first.user_id.should == user_id
      a_event.first.http_method.to_s.should == request.method.downcase
    end

    it "should create multiple VisitEvents when a visit_id visits multiple times" do
      do_some_visits
      Visit::Event.find_all_by_vid(visit_id).should have(3).records
    end

  end

end
