class ApplicationController < ActionController::Base
  # Devise bereits eingebaut - keine include nötig
  
  before_action :set_last_api_fetch
  
  private
  
  def set_last_api_fetch
    @last_api_fetch = ApiStatus.first&.last_fetch_at
    @api_status = ApiStatus.first&.status
  end
  
  def admin_mode?
    controller_path.start_with?('admin/')
  end
  helper_method :admin_mode?
  
  def admin_features_enabled?
    user_signed_in? && current_user.admin?
  end
  helper_method :admin_features_enabled?
  
  def require_admin
    unless admin_features_enabled?
      if user_signed_in?
        redirect_to root_path, alert: 'Admin-Berechtigung erforderlich'
      else
        redirect_to new_user_session_path, alert: 'Bitte melde dich als Admin an'
      end
    end
  end
end