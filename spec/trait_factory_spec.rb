require 'spec_helper'

describe Visit::TraitFactory do
  let(:user) { create :user }

  include_context "gem_config"

  before do
    create :visit_event, url: "http://e.org/articles", user: user, vid: 100
    create :visit_event, url: "http://e.org/articles/1", user: user, vid: 100
  end

  it "creates new traits" do
    expect {
      Visit::TraitFactory.new.run
    }.to change { Visit::Trait.count }.by(2)
  end
end
