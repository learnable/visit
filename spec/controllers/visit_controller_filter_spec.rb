class VisitControllerFilter
end

describe VisitControllerFilter, "Visit::ControllerFilter", :type => :controller do

  controller(VisitControllerFilter) do
    def index
      head :ok
    end
  end

  let(:visit_id) { 555 }

  context "session[:visit_id]" do
    it "should be set when there's no visit_id cookie" do
      get :index
      session.should have_key(:visit_id)
      session[:visit_id].should > 0
    end
    it "should not be set when there's a visit_id cookie" do
      @request.cookies["visit_id"] = visit_id
      get :index
      session.should_not have_key(:visit_id)
    end
  end

  context "#set_event" do

    before :each do
      VisitAttribute.delete_all
      VisitEvent.delete_all
    end

    let(:visit_id_next) { 556 }
    let(:user_id) { 444 }

    def do_visit(path, vid = visit_id, uid = user_id)
      @request.stub(:path) { path }
      @request.cookies["visit_id"] = vid
      if user_id
        create :user, id: user_id if !User.exists?(user_id)
        o = Object.new
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
      a_ve = VisitEvent.find_all_by_visit_id(visit_id_next)
      a_ve.should have(1).records
      a_ve.first.visit_id.should == visit_id_next
      a_ve.first.user_id.should == user_id
      a_ve.first.http_method.should == request.method
    end

    it "should create multiple VisitEvents when a visit_id visits multiple times" do
      do_some_visits
      VisitEvent.find_all_by_visit_id(visit_id).should have(3).records
    end

  end

end
