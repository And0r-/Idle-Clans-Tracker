class DonationProcessorJob < ApplicationJob
  queue_as :default
  
  # Regex patterns für Message-Parsing
  DEPOSIT_PATTERN = /(?<username>\w+) added (?<quantity>\d+)x (?<item_name>.+)\./
  WITHDRAW_PATTERN = /(?<username>\w+) withdrew (?<quantity>\d+)x (?<item_name>.+)\.?/
  
  def perform
    Rails.logger.info "🔄 Processing unprocessed clan logs..."
    
    processed_count = 0
    
    ClanLog.unprocessed.find_each do |clan_log|
      if process_log(clan_log)
        clan_log.update!(processed: true)
        processed_count += 1
      else
        clan_log.update!(processed: true) # Mark as processed even if no donation
      end
    end
    
    Rails.logger.info "✅ Processed #{processed_count} donations"
  end
  
  private
  
  def process_log(clan_log)
    message = clan_log.message
    
    # Try deposit pattern
    if match = message.match(DEPOSIT_PATTERN)
      create_donation(clan_log, match, 'deposit')
      return true
    end
    
    # Try withdraw pattern  
    if match = message.match(WITHDRAW_PATTERN)
      create_donation(clan_log, match, 'withdraw')
      return true
    end
    
    # Not a donation message
    false
  end
  
  def create_donation(clan_log, match, transaction_type)
    username = match[:username]
    quantity = match[:quantity].to_i
    item_name = match[:item_name]
    
    # Find or create member
    member = Member.find_or_create_by(username: username) do |m|
      # total_points wird nicht mehr gesetzt - wird live berechnet
    end
    
    # Create donation OHNE points_value
    Donation.create!(
      member_username: username,
      transaction_type: transaction_type,
      item_name: item_name,
      quantity: quantity,
      # points_value: ENTFERNT - wird live berechnet
      raw_message: clan_log.message,
      occurred_at: clan_log.timestamp
    )
    
    Rails.logger.info "💰 #{transaction_type.capitalize}: #{username} - #{quantity}x #{item_name}"
  end
end