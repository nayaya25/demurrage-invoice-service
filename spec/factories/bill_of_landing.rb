FactoryBot.define do
  factory :bill_of_landing do
    sequence(:id_bl)
    number { Faker::Alphanumeric.alphanumeric(number: 9).upcase }
    arrival_date { Time.current - 5.days }
    freetime { 5 }
    vessel_name { "Vessel X" }
    consignee_name { "Consignee Ltd" }
    exempted { false }
    is_valid { 1 }
    customer
  end
end