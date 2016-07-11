FactoryGirl.define do

  sequence(:email) { |n| "user#{n}@example.org" }

  factory :visit_event, class: Visit::Event do
    ignore do
      url "http://www.example.com"
      user_agent "SomeBrowser 11.0"
    end
    url_id { Visit::SourceValue.find_or_create_by(v: url).id }
    user_agent_id { Visit::SourceValue.find_or_create_by(v: user_agent).id }
    sequence :token
    http_method :get
  end

end
