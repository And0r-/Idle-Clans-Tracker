require 'test_helper'

class DiscordIntegrationTest < ActionDispatch::IntegrationTest
  # Don't load fixtures for these tests
  self.use_instantiated_fixtures = false
  def setup
    # Skip if no test webhook configured
    skip "No test Discord webhook configured" unless ENV['DISCORD_WEBHOOK_URL'].present?
    skip "Using placeholder webhook" if ENV['DISCORD_WEBHOOK_URL'].include?('your_webhook_id')
    
    # Discord settings are loaded from fixtures automatically
  end
  
  test "complete workflow: API import to Discord notification" do
    # Simulate importing clan logs from API
    clan_log = ClanLog.create!(
      clan_name: 'RosaEinhorn',
      member_username: 'IntegrationTest',
      message: 'IntegrationTest has promoted TestPromotee',
      timestamp: Time.current,
      processed: false
    )
    
    # Run ClanActivityDetectorJob
    perform_enqueued_jobs(only: ClanActivityDetectorJob) do
      ClanActivityDetectorJob.perform_now
    end
    
    # Verify ClanActivity was created
    activity = ClanActivity.find_by(message: clan_log.message)
    assert activity, "ClanActivity should be created"
    assert_equal false, activity.discord_notified, "Should not be notified yet"
    
    # Run Discord notification (this sends real Discord message)
    perform_enqueued_jobs(only: DiscordNotificationJob) do
      DiscordNotificationJob.perform_now(activity.id)
    end
    
    # Verify notification was sent
    activity.reload
    assert activity.discord_notified, "Discord notification should be marked as sent"
    
    puts "✅ Integration test sent Discord message: #{activity.message}"
  end
  
  test "multiple activities are processed correctly" do
    activities_data = [
      { username: 'User1', message: 'User1 has promoted NewMember1' },
      { username: 'User2', message: 'User2 gave vault access to NewMember2' },
      { username: 'User3', message: 'User3 has promoted NewMember3' }
    ]
    
    # Create multiple clan logs
    activities_data.each do |data|
      ClanLog.create!(
        clan_name: 'RosaEinhorn',
        member_username: data[:username],
        message: data[:message],
        timestamp: Time.current,
        processed: false
      )
    end
    
    # Process all activities
    perform_enqueued_jobs do
      ClanActivityDetectorJob.perform_now
    end
    
    # Verify all activities were created and notified
    activities_data.each do |data|
      activity = ClanActivity.find_by(message: data[:message])
      assert activity, "ClanActivity should exist for: #{data[:message]}"
      
      activity.reload
      assert activity.discord_notified, "Should be notified: #{data[:message]}"
    end
    
    puts "✅ Integration test sent #{activities_data.length} Discord messages"
  end
  
  test "irrelevant messages are not sent to Discord" do
    # Create logs that should NOT trigger Discord notifications
    irrelevant_logs = [
      'Player completed a quest!',
      'Player added 100x Gold bar.',
      'Player withdrew 50x Magic logs.',
      'Player gained 1000 experience in Mining.'
    ]
    
    initial_activity_count = ClanActivity.count
    
    irrelevant_logs.each do |message|
      ClanLog.create!(
        clan_name: 'RosaEinhorn',
        member_username: 'TestUser',
        message: message,
        timestamp: Time.current,
        processed: false
      )
    end
    
    # Process logs
    ClanActivityDetectorJob.perform_now
    
    # Verify no new activities were created
    assert_equal initial_activity_count, ClanActivity.count, "No activities should be created for irrelevant messages"
    
    puts "✅ Integration test confirmed irrelevant messages are filtered"
  end
  
  private
  
  def perform_enqueued_jobs(only: nil)
    # In test environment, manually perform jobs
    if only
      super(only: only) { yield }
    else
      super { yield }
    end
  end
end