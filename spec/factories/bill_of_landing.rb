FactoryBot.define do
  factory :bill_of_landing do
    sequence(:id_bl) { |n| n }
    number { Faker::Alphanumeric.alphanumeric(number: 9).upcase }
    arrival_date { 10.days.ago }
    freetime { 7 }
    vessel_name { Faker::Vehicle.manufacture }
    consignee_name { Faker::Company.name }
    exempted { false }
    is_valid { 1 }
    status { "VALIDATED" }

    # Container counts - add some variety
    containers_20ft_dry { rand(0..5) }
    containers_40ft_dry { rand(0..3) }
    containers_20ft_reefer { rand(0..2) }
    containers_40ft_reefer { rand(0..1) }
    containers_20ft_special { 0 }
    containers_40ft_special { 0 }

    association :customer

    # Useful traits for testing different scenarios
    trait :recent_arrival do
      arrival_date { 2.days.ago }
    end

    trait :overdue do
      arrival_date { 15.days.ago }
      freetime { 7 }
    end

    trait :becoming_overdue_today do
      arrival_date { 7.days.ago }
      freetime { 7 }
    end

    trait :exempted do
      exempted { true }
    end

    trait :with_many_containers do
      containers_20ft_dry { 10 }
      containers_40ft_dry { 5 }
      containers_20ft_reefer { 3 }
    end

    trait :no_containers do
      containers_20ft_dry { 0 }
      containers_40ft_dry { 0 }
      containers_20ft_reefer { 0 }
      containers_40ft_reefer { 0 }
      containers_20ft_special { 0 }
      containers_40ft_special { 0 }
    end
  end
end