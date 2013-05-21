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
end
