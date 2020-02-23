# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :display do
    title { SecureRandom.urlsafe_base64 12 }
    start_date { 1.month.ago }
    end_date { DateTime.current }

    display_type
  end
end
