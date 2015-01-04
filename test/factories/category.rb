# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :category do
    user
    name { SecureRandom.urlsafe_base64 12 }
  end
end
