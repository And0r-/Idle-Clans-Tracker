class LeaderboardController < ApplicationController
  before_action :set_period
  
  def index
    @members = filtered_members.limit(50)
    @total_members = Member.count
    @total_donations = filtered_donations_sum
    @last_update = ClanLog.maximum(:timestamp)
    @current_period = @period
    
    # Champions für Dashboard
    @champions = load_champions
  end
  
  private
  
  def set_period
    @period = params[:period]&.to_sym || :all
    @period = :all unless [:today, :week, :all].include?(@period)
  end
  
  def load_champions
    {
      all_time: champion_for_period(:all),
      last_week: champion_for_period(:last_week),
      this_week: champion_for_period(:week),
      yesterday: champion_for_period(:yesterday),
      today: champion_for_period(:today)
    }
  end
  
  def champion_for_period(period)
    case period
    when :all
      champion_query(:all)
    when :last_week
      # Letzte Woche in Zürich-Zeit
      last_week_start = 1.week.ago.in_time_zone('Europe/Zurich').beginning_of_week(:sunday)
      last_week_end = 1.week.ago.in_time_zone('Europe/Zurich').end_of_week(:sunday)
      champion_query_with_dates(last_week_start, last_week_end)
    when :week
      # Diese Woche in Zürich-Zeit
      week_start = Time.current.in_time_zone('Europe/Zurich').beginning_of_week(:sunday)
      week_end = Time.current.in_time_zone('Europe/Zurich').end_of_week(:sunday)
      champion_query_with_dates(week_start, week_end)
    when :yesterday
      # Gestern in Zürich-Zeit
      yesterday_start = 1.day.ago.in_time_zone('Europe/Zurich').beginning_of_day
      yesterday_end = 1.day.ago.in_time_zone('Europe/Zurich').end_of_day
      champion_query_with_dates(yesterday_start, yesterday_end)
    when :today
      # Heute in Zürich-Zeit
      today_start = Time.current.in_time_zone('Europe/Zurich').beginning_of_day
      today_end = Time.current.in_time_zone('Europe/Zurich').end_of_day
      champion_query_with_dates(today_start, today_end)
    end
  end
  
  def champion_query(period)
    if period == :all
      Member.joins(:donations)
            .where(donations: { transaction_type: 'deposit', excluded: [false, nil] })
            .joins('LEFT JOIN item_values ON donations.item_name = item_values.item_name AND item_values.active = true')
            .group("members.username")
            .select("members.username, SUM(donations.quantity * COALESCE(item_values.points_per_unit, 0)) as total_points")
            .order("total_points DESC")
            .first
    end
  end
  
  def champion_query_with_dates(start_date, end_date)
    # Sicherstellen dass wir Zürich-Zeit für die Berechnung nutzen
    start_time = start_date.in_time_zone('Europe/Zurich')
    end_time = end_date.in_time_zone('Europe/Zurich')
    Member.joins(:donations)
          .where(donations: { 
            transaction_type: 'deposit', 
            excluded: [false, nil],
            occurred_at: start_date..end_date
          })
          .joins('LEFT JOIN item_values ON donations.item_name = item_values.item_name AND item_values.active = true')
          .group("members.username")
          .select("members.username, SUM(donations.quantity * COALESCE(item_values.points_per_unit, 0)) as total_points")
          .order("total_points DESC")
          .first
  end
  
  def filtered_members
    # SQL für Live-Berechnung je nach Zeitraum
    date_condition = case @period
                    when :today
                      today_start = Time.current.in_time_zone('Europe/Zurich').beginning_of_day
                      today_end = Time.current.in_time_zone('Europe/Zurich').end_of_day
                      "AND donations.occurred_at >= '#{today_start.utc}' AND donations.occurred_at <= '#{today_end.utc}'"
                    when :week
                      week_start = Time.current.in_time_zone('Europe/Zurich').beginning_of_week(:sunday)
                      week_end = Time.current.in_time_zone('Europe/Zurich').end_of_week(:sunday)
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
    base_query = Donation.counted
                        .where(transaction_type: 'deposit')
                        .joins('LEFT JOIN item_values ON donations.item_name = item_values.item_name AND item_values.active = true')
    
    case @period
    when :today
      today_start = Time.current.in_time_zone('Europe/Zurich').beginning_of_day
      today_end = Time.current.in_time_zone('Europe/Zurich').end_of_day
      base_query.where(occurred_at: today_start..today_end)
    when :week
      week_start = Time.current.in_time_zone('Europe/Zurich').beginning_of_week(:sunday)
      week_end = Time.current.in_time_zone('Europe/Zurich').end_of_week(:sunday)
      base_query.where(occurred_at: week_start..week_end)
    else
      base_query
    end.sum('donations.quantity * COALESCE(item_values.points_per_unit, 0)')
  end
end