# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    email "a@b.com"
    password "somelongpassword"
  end
end
