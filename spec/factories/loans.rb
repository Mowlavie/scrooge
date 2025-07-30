FactoryBot.define do
  factory :loan do
    user { nil }
    amount { "9.99" }
    status { "MyString" }
    remaining_balance { "9.99" }
  end
end
