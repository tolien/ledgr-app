# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :page do
    title { SecureRandom.urlsafe_base64 12 }

    factory :owned_page, class: Page do
      user
    end
  end
end
