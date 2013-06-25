require 'spec_helper'

describe "Visit::ControllerFilters", type: :controller do
  # Create an rspec anonymous controller, which by default inherits from
  # ActionController::Base
  controller do
    def index
      if params.has_key? "must_insert"
        if params["must_insert"].nil?
          must_insert_visit_event
        else
          must_insert_visit_event params["must_insert"]
        end
      end

      head :ok
    end
  end

  before { Visit::Configurable.token_cookie_mutator = :visit_tag_controller }
  after { Visit::Configurable.token_cookie_mutator = :visit_tag_controller }

  def token; "0123456789123456"; end

  let(:token_next) { "111next111" }
  let(:user_id) { 444 }

  def prepare_visit(path, opts = {})
    t = opts[:token] || token
    user_id = opts[:user_id]
    @request.stub(:path) { path }
    @request.cookies["token"] = t

    if user_id
      create :user, id: user_id if !User.exists?(user_id)
      o = double
      o.stub(:id) { user_id }
      @controller.stub(:current_user) { o }
    end
  end

  def do_visit(path, opts = {})
    prepare_visit path, opts
    get :index
  end

  def do_some_visits
    do_visit "/"                                            # X visits
    do_visit "/learn/css"                                   # X visits again
    do_visit "/courses/xx-123"                              # X visits again
    do_visit "/courses/blah.js"                             # ignored visit
    do_visit "/system/blah"                                 # ignored visit
    do_visit "/teach", token: token_next, user_id: user_id  # Y visits
  end

  shared_examples "a non altering controller filter" do
    context "when cookie contains a token" do
      it "should not alter session" do
        request.cookies["token"] = token
        get :index
        session.should_not have_key("token")
      end
    end

    context "when session contains a token" do
      it "should not alter cookies" do
        session["token"] = token
        get :index
        response.cookies.should_not have_key("token")
      end
    end
  end

  context "#set_visit_token" do
    context "when Configurable.token_cookie_mutator == :visit_tag_controller" do
      context "when neither session nor cookie contains a token" do
        it_should_behave_like "a non altering controller filter"

        it "should set token in the session (and not cookie)" do
          get :index
          session.should have_key("token")
          session["token"].length.should == Visit::Event::TOKEN_LENGTH
          response.cookies.should_not have_key("token")
        end
      end

    end

    context "when Configurable.token_cookie_mutator :application_controller" do
      before do
        Visit::Configurable.token_cookie_mutator = :application_controller
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

  context "hashes pushed on the :filling queue" do
    let(:h_ignorable) { new_request_payload_hash url: "http://e.org/system/blah/x" }
    let(:h_to_be_inserted) { new_request_payload_hash url: "http://e.org/" }
    let(:h_must_insert) { new_request_payload_hash url: "http://e.org/system/blah/x", must_insert: true }
    let(:queue) { Visit::Configurable.serialized_queue.call(:filling) }

    before { delete_all_visits }

    it "are inserted if :must_insert == true" do
      expect {
        push_onto_filling_queue h_must_insert
        do_some_visits
      }.to change { Visit::Event.count }.by(5)
    end

    it "are inserted if path is not ignorable" do
      expect {
        push_onto_filling_queue h_to_be_inserted
        do_some_visits
      }.to change { Visit::Event.count }.by(5)
    end

    it "are ignored if path is ignorable" do
      expect {
        push_onto_filling_queue h_ignorable
        do_some_visits
      }.to change { Visit::Event.count }.by(4)
    end
  end

  context "must_insert_visit_event" do
    before do
      delete_all_visits
    end

    it "inserts if the request is not ignorable" do
      prepare_visit "/teach"

      get :index, :must_insert => nil
      Visit::Event.count.should == 2 # one for the controller filter, one for must_insert

      Visit::Event.all.first.path == "/teach"
      Visit::Event.all.second.path == "/teach"
    end

    it "inserts even though the request is ignorable" do
      prepare_visit "/system/blah"

      get :index, :must_insert => nil
      Visit::Event.count.should == 1

      Visit::Event.first.path == "/system/blah"
    end

    it "supports a hardcoded path that's different from request.path" do
      path1 = "/system/blah/1"
      path2 = "/system/blah/2"

      prepare_visit path1

      get :index, :must_insert => path2
      Visit::Event.count.should == 1
      Visit::Event.first.path == path2
    end
  end
end
