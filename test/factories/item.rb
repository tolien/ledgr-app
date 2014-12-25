# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :item do
    name { SecureRandom.urlsafe_base64 12 }
    user
  end
end
