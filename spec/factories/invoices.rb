FactoryBot.define do
  factory :invoice do
    sequence(:id_facture)
    reference { Faker::Alphanumeric.alphanumeric(number: 10).upcase }
    amount { 1000 }
    currency { "USD" }
    status { "INIT" }
    issued_date { Time.current }
    user_id { association(:user).id }
    bill_of_landing
  end
end