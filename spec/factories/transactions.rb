FactoryBot.define do
  factory :transaction do
    account { nil }
    transaction_type { "MyString" }
    amount { "9.99" }
    description { "MyString" }
    reference_id { "MyString" }
  end
end
