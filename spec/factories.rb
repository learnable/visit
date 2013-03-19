FactoryGirl.define do

  factory :visit_event, class: Visit::Event do
    sequence(:url) { |n| "https://example#{n}.com/" }
    sequence(:user_agent) { |n| "Chrome #{n}.0" }
    sequence :vid
  end

end
