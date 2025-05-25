class LeaderboardController < ApplicationController
  before_action :set_period
  
  def index
    @members = filtered_members.limit(50)
    @total_members = Member.count
    @total_donations = filtered_donations_sum
    @last_update = ClanLog.maximum(:timestamp)
    @current_period = @period
  end
  
  private
  
  def set_period
    @period = params[:period]&.to_sym || :all
    @period = :all unless [:today, :week, :all].include?(@period)
  end
  
  def filtered_members
    # SQL für Live-Berechnung je nach Zeitraum
    date_condition = case @period
                    when :today
                      "AND donations.occurred_at >= '#{Date.current.beginning_of_day}' AND donations.occurred_at <= '#{Date.current.end_of_day}'"
                    when :week
                      week_start = Date.current.beginning_of_week(:sunday)
                      week_end = week_start.end_of_week(:sunday)
                      "AND donations.occurred_at >= '#{week_start}' AND donations.occurred_at <= '#{week_end}'"
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
    base_query = Donation.counted
                        .where(transaction_type: 'deposit')
                        .joins('LEFT JOIN item_values ON donations.item_name = item_values.item_name AND item_values.active = true')
    
    case @period
    when :today
      base_query.where(occurred_at: Date.current.beginning_of_day..Date.current.end_of_day)
    when :week
      week_start = Date.current.beginning_of_week(:sunday)
      week_end = week_start.end_of_week(:sunday)
      base_query.where(occurred_at: week_start..week_end)
    else
      base_query
    end.sum('donations.quantity * COALESCE(item_values.points_per_unit, 0)')
  end
end