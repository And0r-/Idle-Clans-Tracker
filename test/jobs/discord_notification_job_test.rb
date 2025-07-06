require 'test_helper'

class DiscordNotificationJobTest < ActiveJob::TestCase
  # Don't load fixtures for these tests
  self.use_instantiated_fixtures = false
  def setup
    @clan_activity = ClanActivity.create!(
      member_username: 'TestUser',
      message: 'TestUser has promoted AnotherUser',
      occurred_at: Time.current,
      discord_notified: false
    )
  end
  
  test "should send discord notification successfully" do
    # This is an integration test - it sends real Discord message to test webhook
    skip "Skipping real Discord test" unless ENV['DISCORD_WEBHOOK_URL'].present?
    skip "Using placeholder webhook" if ENV['DISCORD_WEBHOOK_URL'].include?('your_webhook_id')
    
    DiscordNotificationJob.perform_now(@clan_activity.id)
    
    # Verify activity was marked as notified
    @clan_activity.reload
    assert @clan_activity.discord_notified
    
    puts "✅ Real Discord notification sent for test: #{@clan_activity.message}"
  end
  
  test "should skip notification for already notified activities" do
    @clan_activity.update!(discord_notified: true)
    
    # Job should skip already notified activities
    DiscordNotificationJob.perform_now(@clan_activity.id)
    
    # Should remain notified
    @clan_activity.reload
    assert @clan_activity.discord_notified
  end
  
  test "should handle missing clan activity gracefully" do
    # Job should not raise error for non-existent activity
    assert_nothing_raised do
      DiscordNotificationJob.perform_now(99999)
    end
  end
end