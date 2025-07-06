class ApiPollerJob < ApplicationJob
  queue_as :default
  
  def perform
    Rails.logger.info "🔄 Starting API poll for clan logs..."
    
    # API-Status zu Beginn setzen
    api_status = ApiStatus.first_or_create
    api_status.update!(status: 'running', last_fetch_at: Time.current)
    
    api = IdleClansApi.new
    last_timestamp = ClanLog.maximum(:timestamp)
    
    # Smart pagination: start with small limit if we have recent data
    limit = last_timestamp && last_timestamp > 1.hour.ago ? 50 : 100
    skip = 0
    new_logs_count = 0
    
    begin
      loop do
        logs = api.fetch_clan_logs(skip: skip, limit: limit)
        break if logs.empty?
        
        imported_count = import_logs(logs, last_timestamp)
        new_logs_count += imported_count
        
        # Stop if we didn't import any new logs (reached duplicates)
        break if imported_count == 0
        
        skip += limit
        
        # Safety break: don't fetch more than 500 logs in one run
        break if skip >= 500
      end
      
      # Erfolg-Status setzen
      api_status.update!(
        status: 'success',
        logs_imported: new_logs_count,
        last_fetch_at: Time.current
      )
      
      Rails.logger.info "✅ API poll completed. Imported #{new_logs_count} new logs"
      
      # Queue background jobs only if we imported new logs
      # Important: This happens AFTER all database transactions are committed
      # to avoid race conditions where jobs can't see the new records
      if new_logs_count > 0
        # Small delay to ensure database replication in production environments
        DonationProcessorJob.set(wait: 1.second).perform_later
        ClanActivityDetectorJob.set(wait: 1.second).perform_later
        
        Rails.logger.info "📋 Queued background jobs for #{new_logs_count} new logs"
      end
      
    rescue => e
      # Fehler-Status setzen
      api_status.update!(status: "error: #{e.message}")
      Rails.logger.error "❌ API poll failed: #{e.message}"
      raise e
    end
  end
  
  private

  def import_logs(logs, last_timestamp)
    imported = 0
    
    ActiveRecord::Base.transaction do
      logs.each do |log_data|
        timestamp = Time.parse(log_data['timestamp'])
        
        # Skip if we already have this timestamp and it's old
        next if last_timestamp && timestamp <= last_timestamp
        
        clan_log = ClanLog.find_or_initialize_by(
          clan_name: log_data['clanName'],
          member_username: log_data['memberUsername'],
          message: log_data['message'],
          timestamp: timestamp
        )
        
        if clan_log.new_record?
          clan_log.processed = false
          clan_log.save!
          imported += 1
        end
      end
    end
    
    imported
  end
end