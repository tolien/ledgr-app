# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :entry do
    item
    quantity { SecureRandom.random_number(10) + SecureRandom.random_number }
    datetime { DateTime.now.to_s }
    # MySQL <5.6 doesn't use millisecond precision in time values
    # (http://dev.mysql.com/doc/refman/5.6/en/fractional-seconds.html)
    # so wind the created_at and updated_at datetimes back to stop intermittant test fallures
    # where the 'last created' or 'last modified' entry is accessed
    created_at { DateTime.now - 2.seconds }
    updated_at { DateTime.now - 2.seconds }
  end
end
