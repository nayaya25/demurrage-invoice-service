FactoryBot.define do
  factory :customer do
    sequence(:id_client)
    name { "Test Client" }
    code { "CLT123" }
    nom_groupe { "Main Group" }
    paie_caution { true }
    status { "ACTIVE" }
    priority { false }
  end
end