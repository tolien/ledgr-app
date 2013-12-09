# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :display do
    title "MyText"
    start_date 1.month.ago
    end_date DateTime.current
    
    display_type
  end
end
