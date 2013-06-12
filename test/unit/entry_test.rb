require 'test_helper'

class EntryTest < ActiveSupport::TestCase
  test "An entry must be valid" do
    entry = Entry.create()
    assert entry.invalid?
    assert entry.errors[:quantity].include?('is not a number')
    assert entry.errors[:item].include?('can\'t be blank')
    assert entry.errors[:datetime].include?('is not a valid datetime')
    
    
    entry.quantity = 0
    entry.item_id = items(:water).id
    entry.datetime = Time.now
    assert entry.valid?
  end
  
  test "Entry datetime validation" do
    test_entry = entries(:entryone)
    assert test_entry.valid?
    
    test_entry.datetime = 'boingo boingo whoopsy'
    assert test_entry.invalid?
    assert test_entry.errors[:datetime].include? "is not a valid datetime"
    
    test_entry.datetime = '31/2/2013 12:20:00'
    assert test_entry.valid?
    
    test_entry.datetime = '31/2/2013'
    assert test_entry.valid?
    
    test_entry.datetime = '2/31/2013'
    assert test_entry.invalid?
  end
end
