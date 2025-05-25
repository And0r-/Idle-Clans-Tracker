# app/controllers/leaderboard_controller.rb
class LeaderboardController < ApplicationController
  before_action :set_period
  
  def index
    @members = filtered_members.limit(50)
    @total_members = Member.count
    @total_donations = filtered_donations_sum
    @last_update = ClanLog.maximum(:timestamp)
    @current_period = @period
    
    # Champions für Dashboard - jetzt aus dem Model
    @champions = {
      all_time: Member.champion_for_period(:all),
      last_week: Member.champion_for_period(:last_week),
      this_week: Member.champion_for_period(:this_week),
      yesterday: Member.champion_for_period(:yesterday),
      today: Member.champion_for_period(:today)
    }
    
    # Debug: Champion-Werte loggen
    Rails.logger.info "🔍 Dashboard Champions:"
    @champions.each do |period, champion|
      if champion
        Rails.logger.info "  #{period}: #{champion.username} mit #{champion.total_points} Punkten"
      else
        Rails.logger.info "  #{period}: Kein Champion"
      end
    end
  end
  
  private
  
  def set_period
    @period = params[:period]&.to_sym || :all
    @period = :all unless [:today, :week, :all].include?(@period)
  end
  
  def filtered_members
    # SQL für Live-Berechnung je nach Zeitraum
    zurich_tz = ActiveSupport::TimeZone['Europe/Zurich']
    zurich_now = Time.current.in_time_zone(zurich_tz)
    
    date_condition = case @period
                    when :today
                      today_start = zurich_now.beginning_of_day
                      today_end = zurich_now.end_of_day
                      "AND donations.occurred_at >= '#{today_start.utc}' AND donations.occurred_at <= '#{today_end.utc}'"
                    when :week
                      week_start = zurich_now.beginning_of_week(:sunday)
                      week_end = zurich_now.end_of_day
                      "AND donations.occurred_at >= '#{week_start.utc}' AND donations.occurred_at <= '#{week_end.utc}'"
                    else
                      ""
                    end
    
    Member.select("members.id, members.username, members.created_at, members.updated_at, 
                  COALESCE(SUM(donations.quantity * item_values.points_per_unit), 0) as period_points")
          .joins("LEFT JOIN donations ON donations.member_username = members.username 
                                    AND donations.transaction_type = 0 
                                    AND (donations.excluded IS NULL OR donations.excluded = false) 
                                    #{date_condition}")
          .joins("LEFT JOIN item_values ON donations.item_name = item_values.item_name AND item_values.active = true")
          .group("members.id, members.username, members.created_at, members.updated_at")
          .order("period_points DESC")
  end
  
  def filtered_donations_sum
    zurich_tz = ActiveSupport::TimeZone['Europe/Zurich']
    zurich_now = Time.current.in_time_zone(zurich_tz)
    
    base_query = Donation.counted
                        .where(transaction_type: 'deposit')
                        .joins('LEFT JOIN item_values ON donations.item_name = item_values.item_name AND item_values.active = true')
    
    case @period
    when :today
      today_start = zurich_now.beginning_of_day
      today_end = zurich_now.end_of_day
      base_query.where(occurred_at: today_start..today_end)
    when :week
      week_start = zurich_now.beginning_of_week(:sunday)
      week_end = zurich_now.end_of_day
      base_query.where(occurred_at: week_start..week_end)
    else
      base_query
    end.sum('donations.quantity * COALESCE(item_values.points_per_unit, 0)')
  end
end