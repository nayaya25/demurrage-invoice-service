FactoryBot.define do
  factory :refund_request do
    sequence(:id_remboursement)
    bl_number { association(:bill_of_landing).number }
    amount_requested { "1500" }
    status { :pending }
    forwarder_id { 1 }
    request_date { Time.current }
  end
end