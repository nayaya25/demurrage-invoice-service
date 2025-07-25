FactoryBot.define do
  factory :user do
    name { Faker::Internet.user_name }
    email { Faker::Internet.email }
  end
end