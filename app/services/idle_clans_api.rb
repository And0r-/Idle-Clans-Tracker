class IdleClansApi
  include HTTParty
  
  base_uri 'https://query.idleclans.com/api'
  
  def initialize(clan_name = ENV.fetch('CLAN_NAME', 'RosaEinhorn'))
    @clan_name = clan_name
  end
  
  def fetch_clan_logs(skip: 0, limit: 100)
    response = self.class.get("/Clan/logs/clan/#{@clan_name}", {
      query: { skip: skip, limit: limit },
      timeout: 10
    })
    
    if response.success?
      response.parsed_response
    else
      Rails.logger.error "API Error: #{response.code} - #{response.message}"
      []
    end
  rescue => e
    Rails.logger.error "API Exception: #{e.message}"
    []
  end
end