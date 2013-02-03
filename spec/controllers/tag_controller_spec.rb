require "spec_helper"

describe Visit::TagController do

  it "sets a visit_id cookie" do
    get :create
    response.should be_ok
    response.cookies.should have_key("visit_id")
  end

  it "sets correct Content-Type header" do
    get :create
    response.headers["Content-Type"].should == "image/gif; charset=utf-8"
  end

  it "retains existing visit_id cookie" do
    request.cookies["visit_id"] = "1234"
    get :create
    response.should be_ok
    response.cookies.should_not have_key("visit_id")
  end

end
