class LeaderboardController < ApplicationController
  before_action :set_period
  
  def index
    @members = filtered_members.limit(50)
    @total_members = Member.count
    @total_donations = filtered_donations.sum(:points_value)
    @current_period = @period
  end
  
  private
  
  def set_period
    @period = params[:period]&.to_sym || :all
    @period = :all unless [:today, :week, :all].include?(@period)
  end
  
  def filtered_members
    case @period
    when :today
      members_with_period_points(Date.current.beginning_of_day..Date.current.end_of_day, 'daily_points')
    when :week
      week_start = Date.current.beginning_of_week(:sunday)
      week_end = week_start.end_of_week(:sunday)
      members_with_period_points(week_start..week_end, 'weekly_points')
    else # :all
      Member.joins(:donations)
            .where(donations: { transaction_type: 'deposit' })
            .group('members.id, members.username, members.total_points, members.created_at, members.updated_at')
            .order(total_points: :desc)
    end
  end
  
  def members_with_period_points(date_range, points_alias)
    Member.joins(:donations)
          .where(donations: { transaction_type: 'deposit', occurred_at: date_range })
          .group('members.id, members.username, members.total_points, members.created_at, members.updated_at')
          .select("members.*, SUM(donations.points_value) as #{points_alias}")
          .order("#{points_alias} DESC")
  end
  
  def filtered_donations
    case @period
    when :today
      Donation.where(transaction_type: 'deposit', occurred_at: Date.current.beginning_of_day..Date.current.end_of_day)
    when :week
      week_start = Date.current.beginning_of_week(:sunday)
      week_end = week_start.end_of_week(:sunday)
      Donation.where(transaction_type: 'deposit', occurred_at: week_start..week_end)
    else
      Donation.where(transaction_type: 'deposit')
    end
  end
end