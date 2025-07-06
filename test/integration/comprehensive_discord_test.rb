require 'test_helper'

class ComprehensiveDiscordTest < ActionDispatch::IntegrationTest
  # Don't load fixtures for these tests
  self.use_instantiated_fixtures = false
  
  def setup
    # Skip if no test webhook configured
    skip "No test Discord webhook configured" unless ENV['DISCORD_WEBHOOK_URL'].present?
    skip "Using placeholder webhook" if ENV['DISCORD_WEBHOOK_URL'].include?('your_webhook_id')
  end
  
  test "all include keywords should trigger Discord notifications" do
    include_keywords = DiscordSetting.where(keyword_type: 'include', active: true)
    
    test_messages = [
      { keyword: "has promoted", message: "AdminUser has promoted NewMember" },
      { keyword: "gave vault access", message: "AdminUser gave vault access to TrustedMember" },
      { keyword: "has demoted", message: "AdminUser has demoted FormerOfficer" },
      { keyword: "has joined the clan:", message: "NewPlayer has joined the clan: Welcome!" },
      { keyword: "left the clan:", message: "FormerMember left the clan: Goodbye" },
      { keyword: "has kicked", message: "AdminUser has kicked TroubleMaker from the clan" },
      { keyword: "set the clan's", message: "AdminUser set the clan's description to: Best clan ever!" },
      { keyword: "bought the upgrade", message: "AdminUser bought the upgrade: Mining Speed Boost" }
    ]
    
    notifications_sent = 0
    
    test_messages.each do |test_case|
      # Skip if keyword not in fixtures
      next unless include_keywords.any? { |k| k.keyword == test_case[:keyword] }
      
      # Create unprocessed clan log
      clan_log = ClanLog.create!(
        clan_name: 'RosaEinhorn',
        member_username: 'TestAdmin',
        message: test_case[:message],
        timestamp: Time.current,
        processed: false
      )
      
      # Process the activity
      perform_enqueued_jobs do
        ClanActivityDetectorJob.perform_now
      end
      
      # Verify ClanActivity was created
      activity = ClanActivity.find_by(message: test_case[:message])
      assert activity, "ClanActivity should be created for: #{test_case[:message]}"
      
      # Verify Discord notification was sent
      activity.reload
      assert activity.discord_notified, "Discord notification should be sent for: #{test_case[:message]}"
      
      notifications_sent += 1
      puts "✅ Discord notification sent for: #{test_case[:keyword]} -> #{test_case[:message]}"
    end
    
    puts "\n🎉 Total Discord notifications sent: #{notifications_sent}"
    assert notifications_sent > 0, "At least some notifications should be sent"
  end
  
  test "all exclude keywords should NOT trigger Discord notifications" do
    exclude_keywords = DiscordSetting.where(keyword_type: 'exclude', active: true)
    
    test_messages = [
      { keyword: "completed a quest", message: "PlayerX completed a quest!" },
      { keyword: "added", message: "PlayerY added 100x Gold bar." },
      { keyword: "withdrew", message: "PlayerZ withdrew 50x Magic logs." },
      { keyword: "gained experience", message: "PlayerA gained 1000 experience in Mining." }
    ]
    
    initial_activity_count = ClanActivity.count
    
    test_messages.each do |test_case|
      # Skip if keyword not in fixtures
      next unless exclude_keywords.any? { |k| k.keyword == test_case[:keyword] }
      
      # Create unprocessed clan log
      ClanLog.create!(
        clan_name: 'RosaEinhorn',
        member_username: 'TestPlayer',
        message: test_case[:message],
        timestamp: Time.current,
        processed: false
      )
      
      puts "🚫 Should NOT notify for: #{test_case[:keyword]} -> #{test_case[:message]}"
    end
    
    # Process all activities
    ClanActivityDetectorJob.perform_now
    
    # Verify no new activities were created
    final_activity_count = ClanActivity.count
    activities_created = final_activity_count - initial_activity_count
    
    assert_equal 0, activities_created, "No ClanActivities should be created for excluded keywords"
    puts "\n✅ Confirmed: #{test_messages.length} excluded messages were filtered correctly"
  end
  
  test "mixed messages should only notify for relevant ones" do
    mixed_messages = [
      { message: "SuperAdmin has promoted NewOfficer", should_notify: true },
      { message: "PlayerX completed a skilling quest!", should_notify: false },
      { message: "SuperAdmin gave vault access to TrustedPlayer", should_notify: true },
      { message: "PlayerY added 500x Titanium bar.", should_notify: false },
      { message: "NewPlayer has joined the clan: Ready to contribute!", should_notify: true },
      { message: "PlayerZ withdrew 25x Dragon bones.", should_notify: false }
    ]
    
    initial_activity_count = ClanActivity.count
    expected_notifications = mixed_messages.count { |m| m[:should_notify] }
    
    # Create all clan logs
    mixed_messages.each_with_index do |test_case, index|
      ClanLog.create!(
        clan_name: 'RosaEinhorn',
        member_username: "TestUser#{index}",
        message: test_case[:message],
        timestamp: Time.current + index.seconds,
        processed: false
      )
    end
    
    # Process all activities
    perform_enqueued_jobs do
      ClanActivityDetectorJob.perform_now
    end
    
    # Verify correct number of activities created
    final_activity_count = ClanActivity.count
    notifications_sent = final_activity_count - initial_activity_count
    
    assert_equal expected_notifications, notifications_sent,
      "Should create #{expected_notifications} activities, but created #{notifications_sent}"
    
    # Verify each notification was sent correctly
    mixed_messages.each do |test_case|
      activity = ClanActivity.find_by(message: test_case[:message])
      
      if test_case[:should_notify]
        assert activity, "Activity should exist for: #{test_case[:message]}"
        assert activity.discord_notified, "Should be notified: #{test_case[:message]}"
        puts "✅ Notified: #{test_case[:message]}"
      else
        assert_nil activity, "Activity should NOT exist for: #{test_case[:message]}"
        puts "🚫 Filtered: #{test_case[:message]}"
      end
    end
    
    puts "\n🎯 Mixed message test completed: #{notifications_sent}/#{expected_notifications} notifications sent correctly"
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