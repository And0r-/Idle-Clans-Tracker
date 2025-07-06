require 'test_helper'
require 'minitest/mock'

class ApiPollerJobTest < ActiveJob::TestCase
  # Uses fixtures: api_statuses, discord_settings, members, item_values

  test "should queue background jobs with delay after importing logs" do
    # Mock the API response
    api_logs = [
      {
        'clanName' => 'RosaEinhorn',
        'memberUsername' => 'TestUser',
        'message' => 'TestUser has promoted AnotherUser',
        'timestamp' => 1.minute.ago.iso8601
      }
    ]
    
    # Mock IdleClansApi
    mock_api = Minitest::Mock.new
    mock_api.expect(:fetch_clan_logs, api_logs, skip: 0, limit: 100)
    mock_api.expect(:fetch_clan_logs, [], skip: 100, limit: 100)
    
    IdleClansApi.stub(:new, mock_api) do
      assert_enqueued_with(job: DonationProcessorJob, at: 1.second.from_now) do
        assert_enqueued_with(job: ClanActivityDetectorJob, at: 1.second.from_now) do
          ApiPollerJob.perform_now
        end
      end
    end
    
    # Verify the log was imported
    assert_equal 1, ClanLog.count
    assert_equal 'TestUser has promoted AnotherUser', ClanLog.last.message
    assert_equal false, ClanLog.last.processed
    
    # Verify API status was updated
    api_status = ApiStatus.first
    assert_equal 'success', api_status.status
    assert_equal 1, api_status.logs_imported
  end
  
  test "should not queue jobs if no new logs imported" do
    # Mock empty API response
    mock_api = Minitest::Mock.new
    mock_api.expect(:fetch_clan_logs, [], skip: 0, limit: Integer)
    
    IdleClansApi.stub(:new, mock_api) do
      assert_no_enqueued_jobs do
        ApiPollerJob.perform_now
      end
    end
    
    api_status = ApiStatus.first
    api_status.reload
    assert_equal 'success', api_status.status
    assert_equal 0, api_status.logs_imported
  end
  
  test "should handle API errors gracefully" do
    # Mock API error
    mock_api = Minitest::Mock.new
    def mock_api.fetch_clan_logs(skip:, limit:)
      raise StandardError, "API Error"
    end
    
    IdleClansApi.stub(:new, mock_api) do
      assert_raises(StandardError) do
        ApiPollerJob.perform_now
      end
    end
    
    api_status = ApiStatus.first
    api_status.reload
    assert_equal "error: API Error", api_status.status
  end
end