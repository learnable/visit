FactoryGirl.define do

  factory :visit_event, class: Visit::Event do
    url { "https://learnable.com/" }
    vid { 123 }
    factory :visit_event_success do
      url "/membership\/orders\/1234/success/"
    end
    factory :visit_event_course_utm do
      url "/courses/xx-11?utm_source=aa&x=y&utm_medium=bb&utm_content=cc"
    end
  end

end
