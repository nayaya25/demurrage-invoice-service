FactoryBot.define do
  factory :invoice do
    sequence(:id_facture) { |n| n }
    reference { "INV#{Faker::Alphanumeric.alphanumeric(number: 7).upcase}" }
    amount { rand(500..5000) }
    currency { "USD" }
    status { "OPEN" }
    issued_date { Time.current }
    user_id { 1 }

    # Fix: Use the correct foreign key field names
    bl_number { association(:bill_of_landing).number }
    customer_code { association(:customer).code }
    customer_name { association(:customer).name }

    trait :paid do
      status { "PAID" }
    end

    trait :overdue do
      status { "OVERDUE" }
      issued_date { 30.days.ago }
    end
  end
end
