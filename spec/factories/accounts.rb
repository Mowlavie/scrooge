FactoryBot.define do
  factory :account do
    user { nil }
    account_type { "MyString" }
    balance { "9.99" }
    status { "MyString" }
  end
end
