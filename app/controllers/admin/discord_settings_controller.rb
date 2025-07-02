class Admin::DiscordSettingsController < Admin::BaseController
  before_action :set_discord_setting, only: [:edit, :update, :destroy]
  
  def index
    @include_settings = DiscordSetting.where(keyword_type: 'include').order(:keyword)
    @exclude_settings = DiscordSetting.where(keyword_type: 'exclude').order(:keyword)
  end
  
  def new
    @discord_setting = DiscordSetting.new(keyword_type: params[:keyword_type] || 'include')
  end
  
  def create
    @discord_setting = DiscordSetting.new(discord_setting_params)
    
    if @discord_setting.save
      redirect_to admin_discord_settings_path, notice: 'Discord-Einstellung wurde erstellt.'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
  end
  
  def update
    if @discord_setting.update(discord_setting_params)
      redirect_to admin_discord_settings_path, notice: 'Discord-Einstellung wurde aktualisiert.'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    @discord_setting.destroy
    redirect_to admin_discord_settings_path, notice: 'Discord-Einstellung wurde gelöscht.'
  end
  
  def test_webhook
    TestDiscordWebhookJob.perform_later
    redirect_to admin_discord_settings_path, notice: 'Test-Nachricht wird gesendet...'
  end
  
  private
  
  def set_discord_setting
    @discord_setting = DiscordSetting.find(params[:id])
  end
  
  def discord_setting_params
    params.require(:discord_setting).permit(:keyword, :keyword_type, :active, :emoji, :color_hex, :description)
  end
end