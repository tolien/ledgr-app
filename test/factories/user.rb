# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    username { SecureRandom.urlsafe_base64 12 }
    email { "#{SecureRandom.urlsafe_base64 12}@#{SecureRandom.urlsafe_base64 12}.#{SecureRandom.urlsafe_base64 3}" } 
    password { SecureRandom.urlsafe_base64 12 }
    password_confirmation { "#{password}" }
    confirmed_at { Time.now }
  end
end
