FactoryBot.define do
  factory :refund_request do
    sequence(:id_remboursement) { |n| n }
    amount_requested { rand(1000..3000) }
    status { "PENDING" }
    forwarder_id { 1 }
    request_date { Time.current }

    association :bill_of_landing
    bl_number { bill_of_landing.number }

    trait :approved do
      status { "APPROVED" }
    end

    trait :processed do
      status { "PROCESSED" }
    end

    trait :rejected do
      status { "REJECTED" }
    end
  end
end