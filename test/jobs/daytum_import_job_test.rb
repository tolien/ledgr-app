require 'test_helper'

class DaytumImportJobTest < ActiveJob::TestCase
  def setup
    @user = FactoryGirl.create(:user)
    @test_file_path = File.expand_path('../test_files/daytum.csv', __dir__)
  end
  
  test "Import job gets enqueued" do
    assert_enqueued_with(job: DaytumImportJob) do
      @user.import @test_file_path
    end
  end
  
  test "The job actually gets executed and data is imported" do
    perform_enqueued_jobs do
      @user.import @test_file_path
      assert_not_equal 0, @user.items.size

      assert_equal 3, @user.items.size
      assert_equal 3, @user.entries.size
      assert_equal 2, @user.categories.size
    end
  end
end
