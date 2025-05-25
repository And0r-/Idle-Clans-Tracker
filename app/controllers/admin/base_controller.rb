class Admin::BaseController < ApplicationController
  before_action :require_admin
  
  private
  
  def require_admin
    authenticate_admin unless admin_features_enabled?
  end
end