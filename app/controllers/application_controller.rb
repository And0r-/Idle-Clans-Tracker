class ApplicationController < ActionController::Base
  before_action :set_last_api_fetch
  
  private
  
  def set_last_api_fetch
    @last_api_fetch = ApiStatus.first&.last_fetch_at
    @api_status = ApiStatus.first&.status
  end
end