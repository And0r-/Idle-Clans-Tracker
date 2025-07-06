require 'test_helper'

class ClanActivityDetectorJobTest < ActiveJob::TestCase
  # Uses fixtures: discord_settings, members, api_statuses, item_values
  
  test "should create clan activity for relevant messages" do
    # Create unprocessed clan log with relevant message
    clan_log = ClanLog.create!(
      clan_name: 'RosaEinhorn',
      member_username: 'TestUser',
      message: 'TestUser has promoted AnotherUser',
      timestamp: Time.current,
      processed: false
    )
    
    assert_enqueued_with(job: DiscordNotificationJob) do
      ClanActivityDetectorJob.perform_now
    end
    
    # Verify ClanActivity was created
    assert_equal 1, ClanActivity.count
    activity = ClanActivity.last
    assert_equal clan_log.message, activity.message
    assert_equal clan_log.member_username, activity.member_username
    assert_equal false, activity.discord_notified
    
    # Verify ClanLog was marked as processed
    clan_log.reload
    assert clan_log.processed
  end
  
  test "should not create clan activity for irrelevant messages" do
    # Create unprocessed clan log with irrelevant message
    clan_log = ClanLog.create!(
      clan_name: 'RosaEinhorn',
      member_username: 'TestUser',
      message: 'TestUser completed a quest!',
      timestamp: Time.current,
      processed: false
    )
    
    assert_no_enqueued_jobs do
      ClanActivityDetectorJob.perform_now
    end
    
    # Verify no ClanActivity was created
    assert_equal 0, ClanActivity.count
    
    # Verify ClanLog was still marked as processed
    clan_log.reload
    assert clan_log.processed
  end
  
  test "should handle errors without marking log as processed" do
    clan_log = ClanLog.create!(
      clan_name: 'RosaEinhorn',
      member_username: 'TestUser',
      message: 'TestUser has promoted AnotherUser',
      timestamp: Time.current,
      processed: false
    )
    
    # Mock ClanActivity to raise error
    ClanActivity.stub(:find_or_create_by, ->(*args) { raise StandardError, "DB Error" }) do
      # Job should not raise error (it catches them)
      ClanActivityDetectorJob.perform_now
      
      # Verify log is NOT marked as processed
      clan_log.reload
      assert_equal false, clan_log.processed
    end
  end
  
  test "should not create duplicate clan activities" do
    # Create existing ClanActivity
    existing_activity = ClanActivity.create!(
      member_username: 'TestUser',
      message: 'TestUser has promoted AnotherUser',
      occurred_at: Time.current,
      discord_notified: true
    )
    
    # Create unprocessed clan log with same message
    clan_log = ClanLog.create!(
      clan_name: 'RosaEinhorn',
      member_username: 'TestUser',
      message: 'TestUser has promoted AnotherUser',
      timestamp: existing_activity.occurred_at,
      processed: false
    )
    
    # Should not queue Discord notification for already notified activity
    assert_no_enqueued_jobs do
      ClanActivityDetectorJob.perform_now
    end
    
    # Verify no new ClanActivity was created
    assert_equal 1, ClanActivity.count
    
    # Verify ClanLog was marked as processed
    clan_log.reload
    assert clan_log.processed
  end
end