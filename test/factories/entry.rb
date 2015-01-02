# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :entry do
    item
    quantity { SecureRandom.random_number(10) + SecureRandom.random_number }
    datetime { DateTime.now.to_s }
  end
end
