FactoryBot.define do
  factory :customer do
    sequence(:id_client) { |n| n }
    name { Faker::Company.name }
    code { Faker::Alphanumeric.alphanumeric(number: 6).upcase }
    nom_groupe { "Main Group" }
    paie_caution { true }
    status { "ACTIVE" }
    priority { false }

    trait :priority do
      priority { true }
    end

    trait :inactive do
      status { "INACTIVE" }
    end
  end
end