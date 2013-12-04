# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :page do
    title "MyText"
  end
  
  factory :owned_page, class: Page do
    user
  end
end
