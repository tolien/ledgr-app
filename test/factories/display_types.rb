# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :display_type do
    name { "#{SecureRandom.urlsafe_base64 12}" }
  end
end
